import bmtool, math

echo "test1:+"

var
  loopsArray = [1_000, 10_000, 100_000, 1_000_000]
  empty: RunningStat
  stats1: RunningStat
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
  stats1 = doBmCycles(loops, incg)
  stats2 = doBmCycles(loops, inc2)

  echo "cycles stats1 diff=", stats1.min - empty.min, " stats1.min=", stats1.min, " empty.min=", empty.min, " sum=", stats1.sum + empty.sum
  echo "cycles stats2 diff=", stats2.min - empty.min, " stats2.min=", stats2.min, " empty.min=", empty.min, " sum=", stats2.sum + empty.sum
echo ""

# Ticks doesn't work on linux, but is quite good on mac!
for loops in loopsArray:
  empty = doBmTicks(loops, nada())
  stats1 = doBmTicks(loops, incg())
  stats2 = doBmTicks(loops, inc2())

  echo "ticks stats1 diff=", stats1.min - empty.min, " stats1.min=", stats1.min, " empty.min=", empty.min, " sum=", stats1.sum + empty.sum
  echo "ticks stats2 diff=", stats2.min - empty.min, " stats2.min=", stats2.min, " empty.min=", empty.min, " sum=", stats2.sum + empty.sum
echo ""

var outerLoops = 1000
var innerLoops = 1
for z in 1..6:
  innerLoops *= 10

  empty = doBmTime(outerLoops, innerLoops, nada())
  stats1 = doBmTime(outerLoops, innerLoops, incg())
  stats2 = doBmTime(outerLoops, innerLoops, inc2())

  echo "time stats1 diff=", stats1.min - empty.min, " stats1.min=", stats1.min, " empty.min=", empty.min, " sum=", stats1.sum + empty.sum
  echo "time stats2 diff=", stats2.min - empty.min, " stats2.min=", stats2.min, " empty.min=", empty.min, " sum=", stats2.sum + empty.sum
echo ""

echo "test1:-"

