// module Test.Signal

export function tickP (constant, initial, interval, values) {
  var vals = values.slice()
  var out = constant(vals.shift())
  if (vals.length) {
    setTimeout(function pop () {
      out.set(vals.shift())
      if (vals.length) {
        setTimeout(pop, interval)
      }
    }, initial)
  }
  return out
}

export function incEff (val) {
  return function () {
    return val + 1
  }
}

export function incAffP (right) {
  return function (val) {
    return function (callback) {
      return function () {
        setTimeout(function () {
          callback(right(val + 1))()
        }, 0)
      }
    }
  }
}
