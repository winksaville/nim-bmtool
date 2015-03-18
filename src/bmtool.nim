import math, timers

proc getBegCycles*(): tuple[lo: uint32, hi: uint32] {.inline.} =
  # Somewhat dangerous because the compiler isn't tracking the name
  # properly I had to use the field names of the tuple as defined by
  # the code generator. Might be better to use temporaries as I did
  # before an construct the tuple upon exiting but this looks cleaner.
  # One other thing I had to use "return result" since the compiler
  # doesn't understand that the asm statement initialised the result.
  # This comment applies to getEndCycles too.
  asm """
    mfence
    rdtsc
    :"=a"(`result.Field0`), "=d"(`result.Field1`)
  """
  return result

proc getEndCycles*(): tuple[lo: uint32, hi: uint32] {.inline.} =
  asm """
    rdtscp
    mfence
    :"=a"(`result.Field0`), "=d"(`result.Field1`)
  """
  return result

proc measureCycles*(procedure: proc()): int64 =
  ## Returns number of cycles to execute the procedure parameter.
  ## It uses rdtsc/rdtscp and mfence to measure the execution
  ## time as described the Intel paper titled "How to Benchmark
  ## Code Execution Times on Intel IA-32 and IA-64 Instruction Set" 
  var begLo, begHi: uint32
  var endLo, endHi: uint32
  var begCycles, endCycles: int64
  asm """
    mfence
    rdtsc
    :"=a"(`begLo`), "=d"(`begHi`)
  """
  procedure()
  asm """
    rdtscp
    mfence
    :"=a"(`endLo`), "=d"(`endHi`)
  """
  begCycles = int64(begLo) or (int64(begHi) shl 32)
  endCycles = int64(endLo) or (int64(endHi) shl 32)
  result = endCycles - begCycles

template doBmCycles*(procedure: proc(), loops: int, innerLoops: int): RunningStat =
  ## Uses measureCycles to return the RunningStat of executing the procedure parameter.
  ## Since measureCycles has asm statements that don't expand properly in templates we
  ## have to use a proc procedure. This is quite a bit less flexible then being able to
  ## pass an expression but yields probably the second best results but more testing needed.
  var result: RunningStat
  for idx in 0..loops-1:
    for innerIdx in 0..innerLoops-1:
      var cycles = measureCycles(procedure)
      if cycles < 0:
        echo "bad cycles=", cycles
      else:
        result.push(float(cycles))
  result

template doBmCycles2*(benchmarkExpression: expr, loops: int, innerLoops: int): RunningStat =
  ## Uses getBegCycles/getEndCycles to get the cycles and returns the RunningStat.
  ## Since the asm statements are in a procudure we can use a benchmarkExpression parameter
  ## This isn't quite as good as doBmCycles2 or doBmTicks its still pretty good, we'll
  ## have to see how it does on the linux box. And hopefully Araq will be inclined to fix
  ## the bug and we'll be able to use asm statements here in a template.
  var result: RunningStat
  for idx in 0..loops-1:
    for innerIdx in 0..innerLoops-1:
      var begTuple = getBegCycles()
      benchmarkExpression
      var endTuple = getEndCycles()
      var bc = int64(begTuple.lo) or (int64(begTuple.hi) shl 32)
      var ec = int64(endTuple.lo) or (int64(endTuple.hi) shl 32)
      var duration = float(ec - bc)
      if duration < 0:
        echo "bad duration=" & $duration & " ec=" & $float(ec) & " bc=" & $float(bc)
      else:
        result.push(duration)
  result

template doBmTicks*(benchmarkExpression: expr, loops: int, innerLoops: int): RunningStat =
  ## Uses getTicks to return the RunningStat of executing the benchmarkExpression parameter.
  ## On the mac this uses  mac specific and yeilds probably the most consistent results.
  var result: RunningStat
  for idx in 0..loops-1:
    for innerIdx in 0..innerLoops-1:
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
  ## innerLoops to get time per loop. Overall time gives the poorest result
  ## because of the lack of enough resolution relative to ticks or cycles.
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

