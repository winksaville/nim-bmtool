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


for z in 1..8:
  innerLoops *= 10
  var
    stats = doBenchmark(x(2), 100, innerLoops)

  echo "standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats

echo "test1:-"

