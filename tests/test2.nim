import bmtool, math, os
import parseopt2, strutils, tables, pegs


var
  loops = 10
  time = 0.1
  gInt = 3

# TODO: Move command line parsing to a module if this works out
const
  DBG_CL = false # Debug command line

var
  cmdArgs = initTable[string, string]()
  cmdOpts = initTable[string, string]()

for kind, key, val in getopt():
  case kind:
  of cmdShortOption, cmdLongOption:
    cmdOpts[toLower(key)] = val
    case key:
    of "l", "L":
      loops = parseInt(val)
    of "t", "T":
      time = parseFloat(val)
    else:
      discard
  of cmdArgument:
    # Use split to support named value pairs
    var px = peg"':'/'='"
    var arg = split(key, px)
    if arg.len == 2:
      cmdArgs[arg[0]] = arg[1]
    elif arg.len == 1:
      cmdArgs[arg[0]] = ""
    else:
      discard
  else:
    discard

when DBG_CL: echo "cmdArgument: cmdArgs=", cmdArgs
when DBG_CL: echo "cmdArgument: cmdOpts=", cmdOpts


when false:
  block:
    # Lean about simple hash tables and use them to create cmdArgs and cmdOpts
    var
      cmdArgs = initTable[string, string]()
      cmdOpts = initTable[string, string]()

    when DBG_CL: echo "paramCount=" & $paramCount() & " paramStr=" & $commandLineParams()
    for kind, key, val in getopt():
      case kind:
      of cmdShortOption, cmdLongOption:
        cmdOpts[toLower(key)] = val
        case key:
        of "l", "L":
          loops = parseInt(val)
          when DBG_CL: echo "cmdArgument: loop=", loops

        of "t", "T":
          time = parseFloat(val)
          when DBG_CL: echo "cmdArgument: time=", time
        else:
          when DBG_CL: echo "option: ignore key=", key, " val=", val
      of cmdArgument:
        # Use split
        var px = peg"':'/'='"
        var arg = split(key, px)
        if arg.len == 2:
          when DBG_CL: echo "cmdArgument: arg=", $arg
          cmdArgs[arg[0]] = arg[1]
        elif arg.len == 1:
          when DBG_CL: echo "cmdArgument: arg=", $arg
          cmdArgs[arg[0]] = ""
        else:
          when DBG_CL: echo "cmdArgument: split failed"
      else:
        when DBG_CL: echo "ignore: kind=", kind

    when DBG_CL: echo "cmdArgument: cmdArgs=", cmdArgs
    when DBG_CL: echo "cmdArgument: cmdOpts=", cmdOpts
    echo ""


when false:
  # Learn to use Pegs
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
      echo "cmdArgument: key=", key, " val=", val

      # Use split
      var px = peg"':'/'='"
      var arg = split(key, px)
      if arg.len > 0:
        echo "cmdArgument: split px=", px, " arg=", $arg
      else:
        echo "cmdArgument: split failed"

      # Using match
      px = peg"{\ident}(':'/'='){.*}"
      var matches: array[0..1, string]
      if match(key, px, matches):
        echo "cmdArgument: match px=", px
        for i in 0..1:
          echo "cmdArgument: matches[", i, "]",  matches[i]
      else:
        echo "cmdArgument: match failed"

      # Using match operator
      px = peg"{\ident}(':'/'='){.*}"
      if key =~ px:
        echo "cmdArgument: px=", px
        for i in 0..1:
          echo "cmdArgument: matches[", i, "]",  matches[i]
      else:
        echo "cmdArgument: match operator =~ failed"

      # rawMatch would be useful if Captures.ml and Captures.matches
      # where public, but since they aren't you can't do anything :(
      #
      # Also Captures.matches is limited to 20 matches as a
      # fixed sized array, seems we should use sequences or
      # at least take an openArray so it could parse "anything".
      var c: Captures
      var length = rawMatch(key, px, 0, c)
      if length > 0:
        echo "cmdArgument: rawMatch length=", length, " matches.len=", matches.len
      else:
        echo "cmdArgument: rawMatch failed"
    else:
      echo "ignore: kind=", kind

  for cmd in commandLineParams():
    echo "cmd=", cmd
  echo ""

when false:
  block:
    # The measureFor is better :)
    proc doNothing() =
      (discard)

    proc incg(v: int) =
      gInt += v

    var
      rs1: RunningStat
      runTime: float

    # Use the X style, not sure it better but is an alternative and
    # allows you to use the "special syntax". The surprising thing
    # is that I had to append the X instead of overloading the template!
    loops = doBmCyclesCalibration(1.0, doNothing())
    echo "doBmCyclesCalibration doNothing loops=", loops
    timeitX runTime:
      doBmCyclesX loops, rs1:
        doNothing()
    echo "time doNothing=", runTime, " rs1=", rs1
    echo ""

    loops = doBmCyclesCalibration(1.0, incg(2))
    echo "calibarte incg(2) loops=", loops
    echo "time incg(2)=", timeit((rs1 = doBmCycles(loops, incg(2))))
    echo ""
    loops = doBmCyclesCalibration(1.0, sleep(1))
    echo "doBmCyclesCalibration sleep(1) loops=", loops
    echo "time sleep(1)=", timeit((discard doBmCycles(loops, sleep(1))))
    echo ""
    loops = doBmCyclesCalibration(1.0, sleep(10))
    echo "doBmCyclesCalibration sleep(10) loops=", loops
    echo "time sleep(10)=", timeit((discard doBmCycles(loops, sleep(10))))
    echo ""
    loops = doBmCyclesCalibration(1.0, sleep(100))
    echo "doBmCyclesCalibration sleep(100) loops=", loops
    echo "time sleep(100)=", timeit((discard doBmCycles(loops, sleep(100))))
    echo ""
    loops = doBmCyclesCalibration(1.0, sleep(750))
    echo "doBmCyclesCalibration sleep(750) loops=", loops
    echo "time sleep(750)=", timeit((discard doBmCycles(loops, sleep(750))))
    echo ""
    loops = doBmCyclesCalibration(1.0, sleep(1_500))
    echo "doBmCyclesCalibration sleep(1_500) loops=", loops
    echo "time sleep(1_500)=", timeit((discard doBmCycles(loops, sleep(1_500))))
    echo ""
    loops = doBmCyclesCalibration(1.0, sleep(10_000))
    echo "doBmCyclesCalibration sleep(10_000) loops=", loops
    echo "time sleep(10_00)=", timeit((discard doBmCycles(loops, (for x in 0..loops-1: sleep(10_000)))))
    echo ""

when false:
  block:
    proc nada() =
      (discard)

    var tlLoops = doBmCyclesCalibration(1.0, nada())
    echo "tlLoops=", tlLoops
    var
      tlRs: RunningStat
    tlRs = doBmCycles(tlLoops, nada())
    echo "tlRs=", tlRs
    doBmCyclesX tlLoops, tlRs:
      nada()
    echo "tlRs=", tlRs
    echo ""

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
  echo ""


when false:
  proc outer*(s: string) =
    var strg = s

    proc inner() =
      echo "inner says ", strg

    echo "outer says hi"
    inner()

  outer("yo")
  echo ""

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
  echo ""

when false:
  var strg = "global strg"

  template outerT*(s: string, body: stmt) =
    var strg = s
    echo "outerT's strg=", strg
    body

  outerT("yo", echo("yo's body says hi ", strg))
  outerT "me":
    echo "me's body says hi ", strg
  echo ""

when false:
  var
    wp =  newWaitingPeriod(2.0)

  echo "call waiter wp=", wp
  waiter(wp)
  echo "waiter ret  wp=", wp

  delWaitingPeriod(wp)
  echo ""

when false:
  block:
    proc nada() =
      gInt += 1

    echo "measureFor: time=", time
    var rs = measureFor(time, nada())
    echo "rs=", rs
    echo ""

when true:
  if cmdArgs["v"] != nil:
    var v = parseInt(cmdArgs["v"])
    echo "v=", v
    echo "intelinc=", intelinc(v)
    echo "testasm=", testasm(v)
    echo "id=", cpuid(v)
  else:
    echo "Need command line <v=n> where n is some integer"
  echo ""

when true:
  block:
    # Benchmark not enable yet
    proc nada() =
      (discard)

    benchSuite "suite 1":
      setup:
        echo "my setup"

      teardown:
        echo "my teardown"

      bench "nada", 0.5:
        nada()

      var val = 0

      bench "inc", 0.00001:
        val = atomic_add_fetch(addr val, 1, ATOMIC_RELAXED)
        echo "val=", val

    echo ""

