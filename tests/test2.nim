import bmtool, math, os

var
  gInt: int = 3

proc doNothing() =
  (discard)

proc incg(v: int) =
  gInt += v

var loops: int

loops = calibrate(1_000, doNothing())
echo "calibrate doNothing loops=", loops
echo "time doNothing=", timeit(loops, doNothing())
echo ""
loops = calibrate(1_000, incg(2))
echo "calibarte incg(2) loops=", loops
echo "time incg(2)=", timeit(loops, incg(2))
echo ""
loops = calibrate(1_000, sleep(1))
echo "calibrate sleep(1) loops=", loops
echo "time sleep(1)=", timeit(loops, sleep(1))
echo ""
loops = calibrate(1_000, sleep(10))
echo "calibrate sleep(10) loops=", loops
echo "time sleep(10)=", timeit(loops, sleep(10))
echo ""
loops = calibrate(1_000, sleep(100))
echo "calibrate sleep(100) loops=", loops
echo "time sleep(100)=", timeit(loops, sleep(100))
echo ""
loops = calibrate(1_000, sleep(750))
echo "calibrate sleep(750) loops=", loops
echo "time sleep(750)=", timeit(loops, sleep(750))
echo ""
loops = calibrate(1_000, sleep(1_500))
echo "calibrate sleep(1_500) loops=", loops
echo "time sleep(1_500)=", timeit(loops, sleep(1_500))
echo ""
loops = calibrate(1_000, sleep(10_000))
echo "calibrate sleep(10_000) loops=", loops
echo "time sleep(10_00)=", timeit(loops, sleep(10_000))
echo ""

echo "test2:-"
