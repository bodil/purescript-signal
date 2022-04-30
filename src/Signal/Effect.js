// module Signal.Effect

export function mapEffectP (channel) {
  return function (send) {
    return function (action) {
      return function () {
        return function (sig) {
          var initial = action(sig.get())
          var chan = channel(initial)()
          sig.subscribe(function (val) {
            send(chan)(action(val)())()
          })
          return chan
        }
      }
    }
  }
}

export function foldEffectP (make) {
  return function (fun) {
    return function (seed) {
      return function (sig) {
        return function () {
          var acc = seed
          var out = make(acc)
          sig.subscribe(function (val) {
            acc = fun(val)(acc)()
            out.set(acc)
          })
          return out
        }
      }
    }
  }
}
