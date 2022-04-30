// module Signal.Channel

export function channelP (constant) {
  return function (v) {
    return function () {
      return constant(v)
    }
  }
}

export function sendP (chan) {
  return function (v) {
    return function () {
      chan.set(v)
    }
  }
}

export function subscribe (chan) {
  return chan
}
