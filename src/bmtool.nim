import times, math

template doBenchmark*(benchmarkExpression: expr, loops: int, innerLoops: int): RunningStat =
  var result: RunningStat
  for idx in 0..loops-1:
    var st = epochTime()
    for innerIdx in 0..innerLoops-1:
      benchmarkExpression
    var et = epochTime()
    var duration = et - st
    var durationPerInnerLoop = duration/toFloat(innerLoops)
    result.push(durationPerInnerLoop)
  result

