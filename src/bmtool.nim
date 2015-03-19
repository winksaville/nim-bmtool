# The use of cpuid, rtsc, rtsp is from the document from Intel titled
#   "How to Benchmark Code Execution Times on Intel IA-32 and IA-64 Instruction Set Architectures"
# Here is a link to the document:
#   https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0CB4QFjAA&url=http%3A%2F%2Fwww.intel.com%2Fcontent%2Fdam%2Fwww%2Fpublic%2Fus%2Fen%2Fdocuments%2Fwhite-papers%2Fia-32-ia-64-benchmark-code-execution-paper.pdf&ei=GOAKVYnCGdLXoATpjYDACg&usg=AFQjCNEYjOs81ZAayyNeQkswpMNmra86Zg&sig2=EdYam2ml2Ch88rpRXhi4eQ&bvm=bv.88528373,d.cGU
import math, times, timers, os

proc `$`*(r: RunningStat): string =
  "{n=" & $r.n & " sum=" & $r.sum & " min=" & $r.min & " max=" & $r.max & " mean=" & $r.mean & "}"

proc getBegCyclesTuple*(): tuple[lo: uint32, hi: uint32] {.inline.} =
  # Somewhat dangerous because the compiler isn't tracking the name
  # properly I had to use the field names of the tuple as defined by
  # the code generator. Might be better to use temporaries as I did
  # before an construct the tuple upon exiting but this looks cleaner.
  # One other thing I had to use "return result" since the compiler
  # doesn't understand that the asm statement initialised the result.
  # This comment applies to getEndCycles too.
  {.emit: """
    asm volatile(
      "cpuid\n"
      : /* No output */
      : /* No input */
      : "%eax", "%ebx", "%ecx", "%edx");
  """.}
  {.emit: """
    asm volatile(
      "rdtsc\n"
      :"=a"(`result.Field0`), "=d"(`result.Field1`));
  """.}
  return result

proc getBegCycles*(): int64 {.inline.} =
  var lo, hi: uint32
  {.emit: """
    asm volatile(
      "cpuid\n"
      : /* No output */
      : /* No input */
      : "%eax", "%ebx", "%ecx", "%edx");
  """.}
  {.emit: """
    asm volatile(
      "rdtsc\n"
      :"=a"(`lo`), "=d"(`hi`));
  """.}
  result = int64(lo) or (int64(hi) shl 32)

proc getEndCyclesTuple*(): tuple[lo: uint32, hi: uint32] {.inline.} =
  {.emit: """
    asm volatile(
      "rdtscp\n"
      :"=a"(`result.Field0`), "=d"(`result.Field1`));
  """.}
  {.emit: """
    asm volatile(
      "cpuid\n"
      : /* No output */
      : /* No input */
      : "%eax", "%ebx", "%ecx", "%edx");
  """.}
  return result

proc getEndCycles*(): int64 {.inline.} =
  var lo, hi: uint32
  {.emit: """
    asm volatile(
      "rdtscp\n"
      :"=a"(`lo`), "=d"(`hi`));
  """.}
  {.emit: """
    asm volatile(
      "cpuid\n"
      : /* No output */
      : /* No input */
      : "%eax", "%ebx", "%ecx", "%edx");
  """.}
  result = int64(lo) or (int64(hi) shl 32)

proc initialize*() =
  ## Initalize as per the ia32-ia64-benchmark document
  var begLo, begHi: uint32
  var endLo, endHi: uint32
  {.emit: """
    asm volatile(
      "cpuid\n"
      : /* No output */
      : /* No input */
      : "%eax", "%ebx", "%ecx", "%edx");
  """.}
  {.emit: """
    asm volatile(
      "rdtsc\n"
      :"=a"(`begLo`), "=d"(`begHi`));
  """.}
  {.emit: """
    asm volatile(
      "rdtscp\n"
      :"=a"(`endLo`), "=d"(`endHi`));
  """.}
  {.emit: """
    asm volatile(
      "cpuid\n"
      : /* No output */
      : /* No input */
      : "%eax", "%ebx", "%ecx", "%edx");
  """.}
  {.emit: """
    asm volatile(
      "cpuid\n"
      : /* No output */
      : /* No input */
      : "%eax", "%ebx", "%ecx", "%edx");
  """.}
  {.emit: """
    asm volatile(
      "rdtsc\n"
      :"=a"(`begLo`), "=d"(`begHi`));
  """.}
  {.emit: """
    asm volatile(
      "rdtscp\n"
      :"=a"(`endLo`), "=d"(`endHi`));
  """.}
  {.emit: """
    asm volatile(
      "cpuid\n"
      : /* No output */
      : /* No input */
      : "%eax", "%ebx", "%ecx", "%edx");
  """.}

proc measureCycles*(procedure: proc()): int64 =
  ## Returns number of cycles to execute the procedure parameter.
  ## It uses rdtsc/rdtscp and mfence to measure the execution
  ## time as described the Intel paper titled "How to Benchmark
  ## Code Execution Times on Intel IA-32 and IA-64 Instruction Set" 
  var begLo, begHi: uint32
  var endLo, endHi: uint32
  var begCycles, endCycles: int64
  {.emit: """
    asm volatile(
      "cpuid\n"
      : /* No output */
      : /* No input */
      : "%eax", "%ebx", "%ecx", "%edx");
  """.}
  {.emit: """
    asm volatile(
      "rdtsc\n"
      :"=a"(`begLo`), "=d"(`begHi`));
  """.}
  procedure()
  {.emit: """
    asm volatile(
      "rdtsc\n"
      :"=a"(`endLo`), "=d"(`endHi`));
  """.}
  {.emit: """
    asm volatile(
      "cpuid\n"
      : /* No output */
      : /* No input */
      : "%eax", "%ebx", "%ecx", "%edx");
  """.}
  begCycles = int64(begLo) or (int64(begHi) shl 32)
  endCycles = int64(endLo) or (int64(endHi) shl 32)
  result = endCycles - begCycles

template doBmCycles*(procedure: proc(), loops: int): RunningStat =
  ## Uses measureCycles to return the RunningStat of executing the procedure parameter.
  ## Since measureCycles has asm statements that don't expand properly in templates we
  ## have to use a proc procedure. This is quite a bit less flexible then being able to
  ## pass an expression but yields probably the second best results but more testing needed.
  ##
  ## This does yield the do nothing proc call at 42 to 48 cycles on linux.
  var result: RunningStat
  initialize()
  for idx in 0..loops-1:
    var cycles = measureCycles(procedure)
    if cycles >= 0:
      result.push(float(cycles))
  result

template doBmCycles2*(benchmarkExpression: expr, loops: int): RunningStat =
  ## Uses getBegCyclesTuple/getEndCyclesTuple to get the cycles and returns the RunningStat.
  ##
  ## This does yield the do nothing proc call at 78 to 81 cycles fairly consistently on linux.
  var result: RunningStat
  initialize()
  for idx in 0..loops-1:
    var begTuple = getBegCyclesTuple()
    benchmarkExpression
    var endTuple = getEndCyclesTuple()
    var bc = int64(begTuple.lo) or (int64(begTuple.hi) shl 32)
    var ec = int64(endTuple.lo) or (int64(endTuple.hi) shl 32)
    var duration = float(ec - bc)
    if duration < 0:
      echo "bad duration=" & $duration & " ec=" & $float(ec) & " bc=" & $float(bc)
    else:
      result.push(duration)
  result

template doBmCycles3*(benchmarkExpression: expr, loops: int): RunningStat =
  ## Uses getBegCycles/getEndCycles to get the cycles and returns the RunningStat.
  ##
  ## Performance: This does yield the do nothing proc call at 81 to 93 cycles on linux.
  var result: RunningStat
  initialize()
  for idx in 0..loops-1:
    var bc = getBegCycles()
    benchmarkExpression
    var ec = getEndCycles()
    var duration = float(ec - bc)
    if duration < 0:
      echo "bad duration=" & $duration & " ec=" & $float(ec) & " bc=" & $float(bc)
    else:
      result.push(duration)
  result

template doBmTicks*(benchmarkExpression: expr, loops: int): RunningStat =
  ## Uses getTicks to return the RunningStat of executing the benchmarkExpression parameter.
  ## On the mac this uses  mac specific and yeilds probably the most consistent results.
  ##
  ## Performance: On linux this isn't working at all give 0 but on mac is probably the best.
  ## probably need to use inner loop technique as with doBmTime.
  var result: RunningStat
  for idx in 0..loops-1:
    var st = getTicks()
    benchmarkExpression
    var et = getTicks()
    var duration = float(et - st)
    if duration < 0:
      echo "bad duration=" & $duration & " et=" & $float(et) & " st=" & $float(st)
    else:
      result.push(duration)
  result

template doBmTime*(benchmarkExpression: expr, loops: int, innerLoops: int): RunningStat =
  ## Use epochTime to measure. Since one inner loop is to short of a time frame
  ## we measure the time for all of the inner loops then divide by number of
  ## innerLoops to get time per loop.
  ##
  ## Performance: With innerLoops long enough time does we see 3.1 to 2.8ns/loop
  var result: RunningStat
  for idx in 0..loops-1:
    var st = epochTime()
    for innerIdx in 0..innerLoops-1:
      benchmarkExpression
    var et = epochTime()
    var duration = float(et - st)/float(innerLoops)
    if duration < 0:
      echo "bad duration=" & $duration & " et=" & $float(et) & " st=" & $float(st)
    else:
      result.push(duration)
  result

# Execute body loops times and return nanosecs to run
template timeit*(loops: int, body: stmt): float =
  var
    result: float
    startTime: float

  startTime = epochTime()
  for idx in 1..loops:
    body
  result = epochTime() - startTime
  result

template calibrate*(millis: int, body: stmt): int =
  var
    result: int
    guess = 1
    time: float
    maxTime = float(millis) / 1000.0
    minTime = maxTime * 0.95
    goalTime = minTime + ((maxTime - minTime) / 2.0)

  #echo "calibrate:+ goalTime=", goalTime, " minTime=", minTime, " maxTime=", maxtime

  # Find an initial guess
  for loops in 1..20:
    time = timeit(guess, body)
    #echo("calibrate:  ", loops, " time=", time, " guess=", guess)
    if time > (goalTime / 8.0):
      #echo "calibrate:  Initial time=", time, " guess=", guess
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
      #echo("calibrate:  body takes too long, return 1")
      break
    time = timeit(bestGuess, body)

  #echo("calibrate:- time=", time, " bestGuess=", bestGuess)
  result = bestGuess
  result


#template suite(name: expr, body: stmt) {.immediate.} =
#  block:
#    body
#    echo name
