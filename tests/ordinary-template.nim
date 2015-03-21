template declareInt(x: expr) =
  var x : int

declareInt(x) # error: unknown identifier: 'x'
echo "x=", x
