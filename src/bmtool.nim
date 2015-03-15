import timers,math

template doBmTicks*(benchmarkExpression: expr, loops: int, innerLoops: int): RunningStat =
  var result: RunningStat
  for idx in 0..loops-1:
    var st = getTicks()
    for innerIdx in 0..innerLoops-1:
      benchmarkExpression
    var et = getTicks()
    var duration = float(et - st)
    if duration < 0:
      echo "bad duration=" & $duration & " et=" & $float(et) & " st=" & $float(st)
    else:
      result.push(duration/float(innerLoops))
  result

template doBmTime*(benchmarkExpression: expr, loops: int, innerLoops: int): RunningStat =
  var result: RunningStat
  for idx in 0..loops-1:
    var st = epochTime()
    for innerIdx in 0..innerLoops-1:
      benchmarkExpression
    var et = epochTime()
    var duration = float(et - st)
    if duration < 0:
      echo "bad duration=" & $duration & " et=" & $float(et) & " st=" & $float(st)
    else:
      result.push(duration/float(innerLoops))
  result

