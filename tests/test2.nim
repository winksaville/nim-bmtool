import bmtool, math, os
import parseopt2, strutils, hashes, pegs

echo "paramCount=" & $paramCount() & " paramStr=" & $commandLineParams()

var
  loops = 10
  time = 0.1

proc xy(s: string) =
  var matches: array[0..1, string]
  var px = peg"{\ident}':'{.*}"
  var length = matchLen(s, px, matches, 0)
  echo "xy: length=", length, " matches.len=", matches.len
  for i in 0..matches.len-1:
    echo "xy: matches[", i, "]",  matches[i]

for kind, key, val in getopt():
  case kind:
  of cmdShortOption, cmdLongOption:
    echo "option: key=", key, " val=", val
    case key:
    of "l", "L": loops = parseInt(val)
    of "t", "T": time = parseFloat(val)
    else:
      echo "option: ignore key=", key, " val=", val
  of cmdArgument:
    xy(key)
    echo "cmdArgument: key=", key, " val=", val
    var arg = split(key, peg"\:")
    echo "cmdArgument: arg=", $arg

    var px = peg"{\ident}':'{.*}"
    var matches: array[0..1, string]
    var length = matchLen(key, px, matches)
    echo "cmdArgument: number of chars matched length=", length
    for i in 0..1:
      echo "cmdArgument: matches[", i, "]",  matches[i]
    # rawMatch would be useful if Captures.ml and Captures.matches
    # where public, but since they aren't you can't do anything :(
    #
    # Also Captures.matches is limited to 20 matches as a
    # fixed sized array, seems we should use sequences or
    # at least take an openArray so it could parse "anything".
    var c: Captures
    length = rawMatch(key, px, 0, c)
    echo "cmdArgument: length=", length, " matches.len=", matches.len
  else:
    echo "ignore: kind=", kind

for cmd in commandLineParams():
  echo "cmd=", cmd

when false:
  var
    gInt: int = 3

  proc doNothing() =
    (discard)

  proc incg(v: int) =
    gInt += v

  var loops: int

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

when false:
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

when false:
  proc outer*(s: string) =
    var strg = s

    proc inner() =
      echo "inner says ", strg

    echo "outer says hi"
    inner()

  outer("yo")
  inner()

when false:
  # this fails because both innerP and strg not declared
  # in the global scope, I was expecting the temp
  template outerT*(s: string, body: stmt) =
    var strg = s

    proc innerP() =
      echo "innerP called"

    innerP()
    echo "outerT says hi before body"
    body
    echo "outerT says hi after  body"

  outerT "yo":
    innerP()
    echo "yo says hi", strg

when false:
  # this fails because strg is not defined
  template outerT*(s: string, body: stmt) =
    var strg = s

    echo "outerT says hi before body"
    body
    echo "outerT says hi after  body"

  outerT "yo":
    echo "yo says hi ", strg

when false:
  # Succeeds
  template outerT*(s: string, body: stmt) =
    var strg = s

    echo "outerT says hi before body"
    body
    echo "outerT says hi after  body"

  outerT "yo":
    echo "yo says hi"

when false:
  var strg = "global strg"

  template outerT*(s: string, body: stmt) =
    var strg = s
    echo "outerT's strg=", strg
    body

  outerT("yo", echo("yo's body says hi ", strg))
  outerT "me":
    echo "me's body says hi ", strg

when false:
  var
    wp =  newWaitingPeriod(2.0)

  echo "call waiter wp=", wp
  waiter(wp)
  echo "waiter ret  wp=", wp

  delWaitingPeriod(wp)

when true:
  proc nada() =
    (discard)

  var rs = measureFor(time, nada())
  echo "rs=", rs
