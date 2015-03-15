import bmtool, times, math

echo "test1:+"

var
  i = 1

var
  innerLoops = 1

proc x(v: int) =
  i += v

proc `$`*(r: RunningStat): string =
  "{n=" & $r.n & " sum=" & $r.sum & " min=" & $r.min & " max=" & $r.max & " mean=" & $r.mean & "}"


for z in 1..5:
  innerLoops *= 10
  echo "innerLoops=" & $innerLoops

  var
    x = doBenchmark(x(2), 100, innerLoops)
    s: RunningStat

  for v in x:
    var duration = v.endTime - v.startTime
    #echo "duration=" & $duration
    s.push(duration)

  echo "s=" & $s
  echo "variance=" & $s.variance()
  echo "standardDeviation=" & $s.standardDeviation()


echo "test1:-"

