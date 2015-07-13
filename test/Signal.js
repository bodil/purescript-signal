// module Test.Signal

exports.tickP = function tickP(constant, initial, interval, values) {
  var vals = values.slice();
  var out = constant(vals.shift());
  if (vals.length) {
    setTimeout(function pop() {
      out.set(vals.shift());
      if (vals.length) {
        setTimeout(pop, interval);
      }
    }, initial);
  }
  return out;
}
