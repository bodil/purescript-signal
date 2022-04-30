// module Signal

function make (initial) {
  var subs = []
  var val = initial
  var sig = {
    subscribe: function (sub) {
      subs.push(sub)
      sub(val)
    },
    get: function () {
      return val
    },
    set: function (newval) {
      val = newval
      subs.forEach(function (sub) {
        sub(newval)
      })
    }
  }
  return sig
}

export const constant = make

export function mapSig (fun) {
  return function (sig) {
    var out = make(fun(sig.get()))
    sig.subscribe(function (val) {
      out.set(fun(val))
    })
    return out
  }
}

export function applySig (fun) {
  return function (sig) {
    var out = make(fun.get()(sig.get()))
    var produce = function () {
      out.set(fun.get()(sig.get()))
    }
    fun.subscribe(produce)
    sig.subscribe(produce)
    return out
  }
}

export function merge (sig1) {
  return function (sig2) {
    var out = make(sig1.get())
    sig2.subscribe(out.set)
    sig1.subscribe(out.set)
    return out
  }
}

export function foldp (fun) {
  return function (seed) {
    return function (sig) {
      var acc = seed
      var out = make(acc)
      sig.subscribe(function (val) {
        acc = fun(val)(acc)
        out.set(acc)
      })
      return out
    }
  }
}

export function sampleOn (sig1) {
  return function (sig2) {
    var out = make(sig2.get())
    sig1.subscribe(function () {
      out.set(sig2.get())
    })
    return out
  }
}

export function dropRepeatsImpl (eq) {
  return function (sig) {
    var val = sig.get()
    var out = make(val)
    sig.subscribe(function (newval) {
      var areEqual = eq(val)(newval)
      if (!areEqual) {
        val = newval
        out.set(val)
      }
    })
    return out
  }
}

export function dropRepeatsByStrictInequality (sig) {
  var val = sig.get()
  var out = make(val)
  sig.subscribe(function (newval) {
    if (val !== newval) {
      val = newval
      out.set(val)
    }
  })
  return out
}

export function runSignal (sig) {
  return function () {
    sig.subscribe(function (val) {
      val()
    })
    return {}
  }
}

export function unwrap (sig) {
  return function () {
    var out = make(sig.get()())
    sig.subscribe(function (val) {
      out.set(val())
    })
    return out
  }
}

export function filter (fn) {
  return function (seed) {
    return function (sig) {
      var out = make(fn(sig.get()) ? sig.get() : seed)
      sig.subscribe(function (val) {
        if (fn(val)) out.set(val)
      })
      return out
    }
  }
}

export function flattenArray (sig) {
  return function (seed) {
    var first = sig.get().slice()
    if (first.length > 0) {
      seed = first[0]
    } else {
      first = null
    }
    var out = make(seed)
    var feed = function (items) {
      items.forEach(out.set)
    }
    setTimeout(function () {
      sig.subscribe(function (val) {
        if (first === null) {
          feed(val)
        } else {
          feed(first.slice(1))
          first = null
        }
      })
    }, 0)
    return out
  }
}

export function get (sig) {
  return function () {
    return sig.get()
  }
}
