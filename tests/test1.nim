import bmtool, times, math

echo "test1:+"

var
  loopsArray = [1_000, 10_000, 100_000, 1_000_000, 10_000_000]
  empty: RunningStat
  stats: RunningStat
  gInt: int

proc incg() =
  gInt += 1

proc nada() =
  discard

proc `$`*(r: RunningStat): string =
  "{n=" & $r.n & " sum=" & $r.sum & " min=" & $r.min & " max=" & $r.max & " mean=" & $r.mean & "}"

echo ""
echo "Warm up the cpu"
var rs = doBmCycles(nada, 10_000_000)
echo "warm up=", rs

for loops in loopsArray:
  empty = doBmCycles(nada, loops)
  stats = doBmCycles(incg, loops)

  #echo "cycles empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  #echo "cycles stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "cycles min diff=", stats.min - empty.min, " stats.min=", stats.min, " empty.min=", empty.min, " sum=", stats.sum + empty.sum
echo ""

for loops in loopsArray:
  empty = doBmCycles2(nada(), loops)
  stats = doBmCycles2(incg(), loops)

  #echo "cycles2 empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  #echo "cycles2 stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "cycles2 min diff=", stats.min - empty.min, " stats.min=", stats.min, " empty.min=", empty.min, " sum=", stats.sum + empty.sum
echo ""

for loops in loopsArray:
  empty = doBmCycles3(nada(), loops)
  stats = doBmCycles3(incg(), loops)

  #echo "cycles3 empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  #echo "cycles3 stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "cycles3 min diff=", stats.min - empty.min, " stats.min=", stats.min, " empty.min=", empty.min, " sum=", stats.sum + empty.sum
echo ""

# Ticks doesn't work on linux, but is quite good on mac!
for loops in loopsArray:
  empty = doBmTicks(nada(), loops)
  stats = doBmTicks(incg(), loops)

  #echo "ticks empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  #echo "ticks stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "ticks min diff=", stats.min - empty.min, " stats.min=", stats.min, " empty.min=", empty.min, " sum=", stats.sum + empty.sum
echo ""

var outerLoops = 1000
var innerLoops = 1
for z in 1..6:
  innerLoops *= 10

  empty = doBmTime(nada(), outerLoops, innerLoops)
  stats = doBmTime(incg(), outerLoops, innerLoops)

  #echo "time empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  #echo "time stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "time min diff=", stats.min - empty.min, " stats.min=", stats.min, " empty.min=", empty.min, " sum=", stats.sum + empty.sum
echo ""

echo "test1:-"

