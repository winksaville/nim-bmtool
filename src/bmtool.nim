import times

type
  Timer = tuple[startTime: float, endTime: float]

template doBenchmark*(benchmarkExpression: expr, loops: int, innerLoops: int): seq[Timer] {.immediate.} =
  var result: seq[Timer] = newSeq[Timer](loops)
  for idx in 0..loops-1:
    var st = epochTime()
    for innerIdx in 0..innerLoops-1:
      benchmarkExpression
    var et = epochTime()
    result[idx] = (startTime: st, endtime: et)
  result

