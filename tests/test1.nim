import bmtool, math

echo "test1:+"

var
  loopsArray = [1_000, 10_000, 100_000, 1_000_000, 10_000_000]
  empty: RunningStat
  stats: RunningStat
  stats2: RunningStat
  gInt: int
  gInt2: int

proc incg() =
  gInt += 1

proc inc2() =
  gInt += 1
  gInt2 += 1


proc nada() =
  discard

echo ""
echo "Warm up the cpu"
var rs = doBmCycles(10_000_000, nada)
echo "warm up=", rs

for loops in loopsArray:
  empty = doBmCycles(loops, nada)
  stats = doBmCycles(loops, incg)
  stats2 = doBmCycles(loops, inc2)

  #echo "cycles empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  #echo "cycles stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "cycles min stats1 diff=", stats.min - empty.min, " stats.min=", stats.min, " empty.min=", empty.min, " sum=", stats.sum + empty.sum
  echo "cycles min stats2 diff=", stats2.min - empty.min, " stats2.min=", stats2.min, " empty.min=", empty.min, " sum=", stats2.sum + empty.sum
echo ""

for loops in loopsArray:
  empty = doBmCycles2(loops, nada())
  stats = doBmCycles2(loops, incg())
  stats2 = doBmCycles2(loops, inc2())

  #echo "cycles2 empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  #echo "cycles2 stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "cycles2 min stats1 diff=", stats.min - empty.min, " stats.min=", stats.min, " empty.min=", empty.min, " sum=", stats.sum + empty.sum
  echo "cycles2 min stats2 diff=", stats2.min - empty.min, " stats2.min=", stats2.min, " empty.min=", empty.min, " sum=", stats2.sum + empty.sum
echo ""

for loops in loopsArray:
  empty = doBmCycles3(loops, nada())
  stats = doBmCycles3(loops, incg())
  stats2 = doBmCycles3(loops, inc2())

  #echo "cycles3 empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  #echo "cycles3 stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "cycles3 min stats1 diff=", stats.min - empty.min, " stats.min=", stats.min, " empty.min=", empty.min, " sum=", stats.sum + empty.sum
  echo "cycles3 min stats2 diff=", stats2.min - empty.min, " stats2.min=", stats2.min, " empty.min=", empty.min, " sum=", stats2.sum + empty.sum
echo ""

# Ticks doesn't work on linux, but is quite good on mac!
for loops in loopsArray:
  empty = doBmTicks(loops, nada())
  stats = doBmTicks(loops, incg())
  stats2 = doBmTicks(loops, inc2())

  #echo "ticks empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  #echo "ticks stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "ticks min stats1 diff=", stats.min - empty.min, " stats.min=", stats.min, " empty.min=", empty.min, " sum=", stats.sum + empty.sum
  echo "ticks min stats2 diff=", stats2.min - empty.min, " stats2.min=", stats2.min, " empty.min=", empty.min, " sum=", stats2.sum + empty.sum
echo ""

var outerLoops = 1000
var innerLoops = 1
for z in 1..6:
  innerLoops *= 10

  empty = doBmTime(outerLoops, innerLoops, nada())
  stats = doBmTime(outerLoops, innerLoops, incg())
  stats2 = doBmTime(outerLoops, innerLoops, inc2())

  #echo "time empty standardDeviation=" & $empty.standardDeviation() & " innerLoops=" & $innerLoops & " empty=" & $empty
  #echo "time stats standardDeviation=" & $stats.standardDeviation() & " innerLoops=" & $innerLoops & " stats=" & $stats
  echo "time min stats1 diff=", stats.min - empty.min, " stats.min=", stats.min, " empty.min=", empty.min, " sum=", stats.sum + empty.sum
  echo "time min stats2 diff=", stats2.min - empty.min, " stats2.min=", stats2.min, " empty.min=", empty.min, " sum=", stats2.sum + empty.sum
echo ""

echo "test1:-"

