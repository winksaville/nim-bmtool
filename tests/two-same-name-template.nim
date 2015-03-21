template t1(name: string) {.immediate.} =
  echo "t1(name: string) name=", name

template t1(i: int) {.immediate.} =
  echo "t1(i: int) i=", i

t1("a-name")
let i=2
t1(i)
