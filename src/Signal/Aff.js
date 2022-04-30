// module Signal.Aff

export function mapAffP (runAff_) {
  return function (mkChannel) {
    return function (sendEither) {
      return function (action) {
        return function () {
          return function (sig) {
            var chan = mkChannel()
            var send = sendEither(chan)
            var runAction = runAff_(send)
            sig.subscribe(function (val) {
              runAction(action(val))()
            })
            return chan
          }
        }
      }
    }
  }
}
