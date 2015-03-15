import bmtool, times, math

echo "test1:+"

var
  i = 1

var
  innerLoops = 1

proc x(v: int) =
  i += v

proc y() =
  discard

proc `$`*(r: RunningStat): string =
  "{n=" & $r.n & " sum=" & $r.sum & " min=" & $r.min & " max=" & $r.max & " mean=" & $r.mean & "}"


for z in 1..4:
  innerLoops *= 10
  var
    empty = doBmTicks(y(), 10000, innerLoops)
    stats = doBmTicks(x(2), 10000, innerLoops)

  echo "empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  echo "stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "min diff=" & $(stats.min - empty.min)

innerLoops = 1

echo ""

for z in 1..5:
  innerLoops *= 10
  var
    empty = doBmTime(y(), 10000, innerLoops)
    stats = doBmTime(x(2), 10000, innerLoops)

  echo "empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  echo "stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "min diff=" & $(stats.min - empty.min)

echo "test1:-"

