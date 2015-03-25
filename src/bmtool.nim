# The use of cpuid, rtsc, rtsp is from the document from Intel titled
#   "How to Benchmark Code Execution Times on Intel IA-32 and IA-64 Instruction Set Architectures"
# Here is a link to the document:
#   https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0CB4QFjAA&url=http%3A%2F%2Fwww.intel.com%2Fcontent%2Fdam%2Fwww%2Fpublic%2Fus%2Fen%2Fdocuments%2Fwhite-papers%2Fia-32-ia-64-benchmark-code-execution-paper.pdf&ei=GOAKVYnCGdLXoATpjYDACg&usg=AFQjCNEYjOs81ZAayyNeQkswpMNmra86Zg&sig2=EdYam2ml2Ch88rpRXhi4eQ&bvm=bv.88528373,d.cGU
import math, times, timers, os, posix, strutils

type
  CpuId = tuple
    eax: int
    ebx: int
    ecx: int
    edx: int

var
  gInt2*: int

proc `$`*(r: RunningStat): string =
  "{n=" & $r.n & " sum=" & $r.sum & " min=" & $r.min & " max=" & $r.max & " mean=" & $r.mean & "}"

proc `$`*(ts: Ttimespec): string =
  "{" & $cast[int](ts.tv_sec) & "," & $ts.tv_nsec & "}"

proc `$`*(cpuid: CpuId): string =
  "{ eax=0x" & cpuid.eax.toHex(8) & " ebx=0x" & cpuid.ebx.toHex(8) & " ecx=0x" & cpuid.ecx.toHex(8) & " edx=0x" & cpuid.edx.toHex(8) & "}"


when defined(macosx):
  # Doesn't seem macosx support intel_syntax
  # although it doesn't generate any errors the
  # code doesn't increment the parameter
  proc intelinc*(param: int): int =
    # Increment the input parameter
    {.emit: """
      asm volatile (".att_syntax");
      asm volatile (
        "movq %1, %%rax\n\t"
        "incq %%rax\n\t"
        "movq %%rax, %0\n\t"
        : "=r"(`result`)
        : "r"(`param`));
      asm volatile (".att_syntax");
    """.}
    return result

  # mac does not support noprefix!!
  proc testasm*(param: int): int =
    # Increment the input parameter
    {.emit: """
      asm volatile (".att_syntax");
      asm volatile (
        "movq %1, %%rax\n\t"
        "incq %%rax\n\t"
        "movq %%rax, %0\n\t"
        : "=r"(`result`)
        : "r"(`param`));
      asm volatile (".att_syntax");
    """.}
    return result
else:
  proc intelinc*(param: int): int =
    # Increment the input parameter
    {.emit: """
      asm volatile (".intel_syntax");
      asm volatile (
        "movq %%rax, %1\n\t"
        "incq %%rax\n\t"
        "movq %0, %%rax\n\t"
        : "=r"(`result`)
        : "r"(`param`));
      asm volatile (".att_syntax");
    """.}
    return result

  proc testasm*(param: int): int =
    # Increment the input parameter
    {.emit: """
      asm volatile (".att_syntax noprefix");
      asm volatile (
        "movq %1, rax\n\t"
        "incq rax\n\t"
        "movq rax, %0\n\t"
        : "=r"(`result`)
        : "r"(`param`));
      asm volatile (".att_syntax");
    """.}
    return result

proc cpuid*(ax_param: int): CpuId =
  {.emit: """
    asm volatile (
      "movq %4, %%rax\n\t"
      "cpuid\n\t"
      : "=a"(`result.Field0`), "=b"(`result.Field1`), "=c"(`result.Field2`), "=d"(`result.Field3`)
      : "r"(`ax_param`));
  """.}

proc cpuid() {.inline.} =
  {.emit: """
    asm volatile (
      "cpuid\n\t"
      : /* Throw away output */
      : /* No input */
      : "%eax", "%ebx", "%ecx", "%edx");
  """.}

proc rdtsc*(): int64 {.inline.} =
  var lo, hi: uint32
  {.emit: """
    asm volatile (
      "rdtsc\n\t"
      :"=a"(`lo`), "=d"(`hi`));
  """.}
  result = int64(lo) or (int64(hi) shl 32)

proc rdtscp*(): int64 {.inline.} =
  var lo, hi: uint32
  {.emit: """
    asm volatile (
      "rdtscp\n\t"
      :"=a"(`lo`), "=d"(`hi`));
  """.}
  result = int64(lo) or (int64(hi) shl 32)

proc rdtscp*(tscAux: var int): int64 {.inline.} =
  var lo, hi, aux: uint32
  {.emit: """
    asm volatile (
      "rdtscp\n\t"
      :"=a"(`lo`), "=d"(`hi`), "=c"(`aux`));
  """.}
  tscAux = cast[int](aux)
  result = int64(lo) or (int64(hi) shl 32)

proc getBegCycles*(): int64 {.inline.} =
  cpuid()
  result = rdtsc()

proc getEndCycles*(): int64 {.inline.} =
  result = rdtscp()
  cpuid()

proc getEndCycles*(tscAux: var int): int64 {.inline.} =
  result = rdtscp(tscAux)
  cpuid()

proc initializeCycles() {.inline.} =
  ## Initalize as per the ia32-ia64-benchmark document
  discard getBegCycles()
  discard getEndCycles()
  discard getBegCycles()
  discard getEndCycles()

proc initializeCycles(tscAux: var int): int {.inline.} =
  ## Initalize as per the ia32-ia64-benchmark document returning
  ## the tsc value as exiting and the tscAux in the var param
  discard getBegCycles()
  discard getEndCycles()
  discard getBegCycles()
  result = cast[int](getEndCycles(tscAux))

template doBmCycles*(loops: int, body: stmt): RunningStat =
  ## Uses measureCycles to return the RunningStat of executing the procedure parameter.
  var result: RunningStat
  initializeCycles()
  for idx in 0..loops-1:
    var begCycles = getBegCycles()
    body
    var cycles = getEndCycles() - begCycles
    if cycles >= 0:
      result.push(float(cycles))
  result

template doBmCyclesX*(loops: int, rs: var RunningStat, body: stmt) =
  ## Uses measureCycles to return the RunningStat of executing the procedure parameter.
  initializeCycles()
  for idx in 0..loops-1:
    var begCycles = getBegCycles()
    body
    var cycles = getEndCycles() - begCycles
    if cycles >= 0:
      rs.push(float(cycles))

template doBmTicks*(loops: int, body: stmt): RunningStat =
  ## Uses getTicks to return the RunningStat of executing the body parameter.
  ## On the mac this uses  mac specific and yeilds probably the most consistent results.
  ##
  ## Performance: On linux this isn't working at all give 0 but on mac is probably the best.
  ## probably need to use inner loop technique as with doBmTime.
  const DBG = false
  var result: RunningStat
  for idx in 0..loops-1:
    var st = getTicks()
    body
    var et = getTicks()
    var duration = float(et - st)
    if duration < 0:
      when DBG: echo "bad duration=" & $duration & " et=" & $float(et) & " st=" & $float(st)
    else:
      result.push(duration)
  result

template doBmTime*(loops: int, innerLoops: int, body: stmt): RunningStat =
  ## Use epochTime to measure. Since one inner loop is to short of a time frame
  ## we measure the time for all of the inner loops then divide by number of
  ## innerLoops to get time per loop.
  ##
  ## Performance: With innerLoops long enough time does we see 3.1 to 2.8ns/loop
  const DBG = false
  var result: RunningStat
  for idx in 0..loops-1:
    var st = epochTime()
    for innerIdx in 0..innerLoops-1:
      body
    var et = epochTime()
    var duration = float(et - st)/float(innerLoops)
    if duration < 0:
      when DBG: echo "bad duration=" & $duration & " et=" & $float(et) & " st=" & $float(st)
    else:
      result.push(duration)
  result

template timeit*(body: stmt): float =
  ## Execute body and return nanosecs to run
  var
    result: float
    startTime: float

  startTime = epochTime()
  body
  result = epochTime() - startTime
  result

template timeitX*(time: var float, body: stmt) =
  ## Execute body and return nanosecs to run in time
  var
    startTime: float

  startTime = epochTime()
  body
  time = epochTime() - startTime

template doBmCyclesCalibration*(seconds: float, body: stmt): int =
  ## Calibrate number of loops doBmCycles needs to execute for
  ## the time specified by the seconds parameter.
  const DBG = false
  var
    result: int
    guess = 1
    time: float
    maxTime = seconds
    minTime = maxTime * 0.95
    goalTime = minTime + ((maxTime - minTime) / 2.0)

  when DBG: echo "calibrate:+ goalTime=", goalTime, " minTime=", minTime, " maxTime=", maxtime

  # Find an initial guess
  for loops in 1..20:
    time = timeit((discard doBmCycles(guess, body)))
    when DBG: echo("calibrate:  ", loops, " time=", time, " guess=", guess)
    if time > (goalTime / 8.0):
      when DBG: echo "calibrate:  Initial time=", time, " guess=", guess
      break
    else:
      guess *= 4

  # Search for something closer calculating timePerLoop
  # and then a newGuess. If the bestGuess and oldGuess
  # are equal or if bestGuess <= 0 then this is the best
  # we can do. This happens when the time per loop is
  # large and we can't converge.
  var oldGuess = 0
  var bestGuess = guess
  while (oldGuess != bestGuess) and ((time < minTime) or (time > maxTime)):
    oldGuess = bestGuess
    var timePerLoop = time / float(oldGuess)
    bestGuess = round(goalTime / timePerLoop)
    if bestGuess <= 0:
      bestGuess = 1
      when DBG: echo("calibrate:  body takes too long, return 1")
      break
    time = timeit((discard doBmCycles(bestGuess, body)))

  when DBG: echo("calibrate:- time=", time, " bestGuess=", bestGuess)
  result = bestGuess
  result

proc wait*(seconds: float) =
  ## This is equivalent to sleep(round(wp.seconds * 1000.0))
  ## But is generally more robust as it is able to continue
  ## waiting if it was interrupted. And is capable of waiting
  ## for less than a millisecond.
  if seconds <= 0.0:
    return

  var
    sleepTime, remainingTime: Ttimespec
  remainingTime.tv_sec = cast[Time](round(trunc(seconds)))
  remainingTime.tv_nsec = round((seconds - trunc(seconds)) * 1.0e9)

  var done = false
  while not done:
    sleepTime = remainingTime
    var result = posix.nanosleep(sleepTime, remainingTime)
    if result == 0 or result == -1 and posix.errno != EINTR:
      # We completed successful or the error wasn't EINTR so be done
      done = true

type
  WaitingPeriod* = object
    seconds: float
    done: bool

proc `$`*(wp: ptr WaitingPeriod): string =
  "{" & $wp.seconds & "," & $wp.done & "}"

proc newWaitingPeriod*(seconds: float): ptr WaitingPeriod =
  ## Return a new shareable WaitingPeriod
  result = cast[ptr WaitingPeriod](allocShared(sizeof(WaitingPeriod)))
  result.seconds = seconds
  result.done = false

proc delWaitingPeriod*(wp: ptr WaitingPeriod) =
  ## Delete the shareable WaitingPeriod
  deallocShared(wp)

proc waiter*(wp: ptr WaitingPeriod) =
  ## Wait wp.seconds and set wp.done when complete
  wait(wp.seconds)
  atomicstoreN(addr wp.done, true, ATOMIC_RELEASE)

proc cps(seconds: float): int =
  ## Try to determine the cycles per second of the TSC
  ## seconds is how long to meausre. return -1 if unsuccessful
  ## or its the number of cycles per second
  const
    DBG = true

  var
    wp: ptr WaitingPeriod
    wt: TThread[ptr WaitingPeriod]
    tscAuxInitial: int
    tscAuxNow: int
    start : int
    ec : int

  try:
    wp = newWaitingPeriod(seconds)
    createThread(wt, waiter, wp)
    start = initializeCycles(tscAuxInitial)
    when DBG: echo "tscAuxInitial=0x", tscAuxInitial.toHex(4)
    while not atomicLoadN(addr wp.done, ATOMIC_ACQUIRE):
      ec = cast[int](getEndCycles(tscAuxNow))
      if tscAuxInitial != tscAuxNow:
        when DBG: echo "bad tscAuxNow=0x", tscAuxNow.toHex(4), " != tscAuxInitial=0x", tscAuxInitial.toHex(4)
        return -1
    result = round((ec - start).toFloat() / seconds)
  finally:
    # Wait until the time has expired so we can delete the waiting period
    while not atomicLoadN(addr wp.done, ATOMIC_ACQUIRE):
      sleep(10)
    delWaitingPeriod(wp)

proc cyclesPerSecond*(seconds: float): int =
  for i in 0..2:
    result = cps(seconds)
    if result != -1:
      return result
  result = -1

template measureFor*(cycles: int, body: stmt): RunningStat =
  ## Meaure the execution time of body for cycles count of TSC
  ## returning the RunningStat for the loop timings. If
  ## RunningStat.n = -1 and RunningStat.min == -1 then an error occured.

  const
    DBG = true
    DBGV = false

  var
    result: RunningStat
    tscAuxInitial: int
    tscAuxNow: int
    start: int
    done: int
    bc : int64
    ec : int64

  # TODO: Handle wrapping of counter!
  start = initializeCycles(tscAuxInitial)
  done = start + cycles
  when DBG: echo "tscAuxInitial=0x", tscAuxInitial.toHex(4)
  ec = 0
  while ec <= done:
    bc = getBegCycles()
    body
    ec = getEndCycles()
    var duration = float(ec - bc)
    when DBGV: echo "duration=", duration, " ec=", float(ec), " bc=", float(bc)
    if tscAuxInitial != tscAuxNow:
      when DBG: echo "bad tscAuxNow=0x", tscAuxNow.toHex(4), " != tscAuxInitial=0x", tscAuxInitial.toHex(4)
      result.n = -1
      result.min = -1
      break
    if duration < 0.0:
      when DBG: echo "ignore duration=", duration, " ec=", float(ec), " bc=", float(bc)
    else:
      result.push(duration)
  result

when true:

  template benchSetupImpl*: stmt {.immediate, dirty.} = discard

  template benchTeardownImpl*: stmt {.immediate, dirty.} = discard

  # TODO: How to make suiteName available to benchSuiteBody
  template benchSuite*(suiteName: expr, benchSuiteBody: stmt): stmt {.immediate, dirty.} =
    echo "suite name=", suiteName

    # TODO: setup and teardown are valid past the life time of a particulare benchSuite
    # becuase benchSetupImpl and benchTeardownImpl are global so when setup and teardown
    # are instantiated they remain after after a particlare benchSuite ends. Not the best
    template setup*(setupBody: stmt): stmt {.immediate, dirty.} =
      template benchSetupImpl: stmt {.immediate, dirty.} = setupBody

    template teardown*(teardownBody: stmt): stmt {.immediate, dirty.} =
      template benchTeardownImpl: stmt {.immediate, dirty.} = teardownBody

    benchSuiteBody

  # Pragma .dirty. is needed to inject benchSetupImpl and benchTeardownImpl and allow them to be overridden
  # with each bench invocation. Pragma .immediate. is not needed because there is nothing to inject for benchBody?
  #
  # TODO: How to make benchName available to the bench and benchSuite?
  template bench*(benchName: expr, cycles: int, runningStat: var RunningStat, benchBody: stmt): stmt {.immediate, dirty.} =
    echo "bench name=", benchName
    benchSetupImpl()

    runningStat = measureFor(cycles, benchBody)

    benchTeardownImpl()
