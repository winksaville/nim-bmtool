import bmtool, math, os

var
  gInt: int = 3

proc doNothing() =
  (discard)

proc incg(v: int) =
  gInt += v

var loops: int

when false:
  loops = calibrate(1.0, doNothing())
  echo "calibrate doNothing loops=", loops
  echo "time doNothing=", timeit(doBmCycles2(loops, doNothing()))
  echo ""
  #loops = calibrate(1.0, incg(2))
  #echo "calibarte incg(2) loops=", loops
  #echo "time incg(2)=", timeit(loops, incg(2))
  #echo ""
  #loops = calibrate(1.0, sleep(1))
  #echo "calibrate sleep(1) loops=", loops
  #echo "time sleep(1)=", timeit(loops, sleep(1))
  #echo ""
  #loops = calibrate(1.0, sleep(10))
  #echo "calibrate sleep(10) loops=", loops
  #echo "time sleep(10)=", timeit(loops, sleep(10))
  #echo ""
  #loops = calibrate(1.0, sleep(100))
  #echo "calibrate sleep(100) loops=", loops
  #echo "time sleep(100)=", timeit(loops, sleep(100))
  #echo ""
  #loops = calibrate(1.0, sleep(750))
  #echo "calibrate sleep(750) loops=", loops
  #echo "time sleep(750)=", timeit(loops, sleep(750))
  #echo ""
  #loops = calibrate(1.0, sleep(1_500))
  #echo "calibrate sleep(1_500) loops=", loops
  #echo "time sleep(1_500)=", timeit(loops, sleep(1_500))
  #echo ""
  #loops = calibrate(1.0, sleep(10_000))
  #echo "calibrate sleep(10_000) loops=", loops
  #echo "time sleep(10_00)=", timeit((for x in 0..loops-1: sleep(10_000)))
  #echo ""

when false:
  block:
    proc nada() =
      (discard)

    var tlLoops = calibrate(1.0, nada())
    echo "tlLoops=", tlLoops
    var
      tlRs: RunningStat
    tlRs = doBmCycles2(tlLoops, nada())
    echo "tlRs=", tlRs

when true:
    proc nada() =
      (discard)

    benchSuite "suite 1":
      bench "nada":
        nada()

when false:

  template initImpl*: stmt {.immediate, dirty.} = discard

  template tlTempl*(name: string, body: stmt) {.immediate, dirty.} =
    block:
      echo "tlTempl: name=", name

      template init*(initBody: stmt): stmt {.immediate, dirty.} =
        template initImpl: stmt {.immediate, dirty.} = initBody

      body

  template doit*(name: expr, body: stmt): stmt {.immediate, dirty.} =
    initImpl()
    body

  tlTempl "my_tlTempl":
    init:
      echo "my init"

    doit "doit1":
      echo "do'n it"


when false:
  block:
    var v = xyz()
    echo "val=", val
    echo "v=", v

echo "test2:-"
