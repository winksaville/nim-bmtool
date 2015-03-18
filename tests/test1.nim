import bmtool, times, math

echo "test1:+"

var
  i = 1

const
  outerLoops = 1000

var
  innerLoops = 1

proc y() =
  discard

var
  zv: int
proc zproc() =
  zv += 1

proc `$`*(r: RunningStat): string =
  "{n=" & $r.n & " sum=" & $r.sum & " min=" & $r.min & " max=" & $r.max & " mean=" & $r.mean & "}"

var
  empty: RunningStat
  stats: RunningStat

var
  cy = measureCycles(y)
echo "measureCyclesExpr(y)=", cy

var rs = doBmCycles(y, outerLoops, innerloops)
echo "doBmCycles(y)=", rs

innerLoops = 1
for z in 1..4:
  innerLoops *= 10

  empty = doBmCycles(y, outerLoops, innerLoops)
  stats = doBmCycles(zproc, outerLoops, innerLoops)

  echo "cycles empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  echo "cycles stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "cycles min diff=" & $(stats.min - empty.min)


echo ""

innerLoops = 1
for z in 1..4:
  innerLoops *= 10

  empty = doBmCycles2(y(), outerLoops, innerLoops)
  stats = doBmCycles2(zproc(), outerLoops, innerLoops)

  echo "cycles2 empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  echo "cycles2 stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "cycles2 min diff=" & $(stats.min - empty.min)


echo ""

innerLoops = 1
for z in 1..4:
  innerLoops *= 10

  empty = doBmTicks(y(), outerLoops, innerLoops)
  stats = doBmTicks(zproc(), outerLoops, innerLoops)

  echo "ticks empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  echo "ticks stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "ticks min diff=" & $(stats.min - empty.min)


echo ""

innerLoops = 1
for z in 1..4:
  innerLoops *= 10
  var
    empty = doBmTime(y(), outerLoops, innerLoops)
    stats = doBmTime(zproc(), outerLoops, innerLoops)

  echo "time empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  echo "time stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "time min diff=" & $(stats.min - empty.min)

echo "test1:-"

