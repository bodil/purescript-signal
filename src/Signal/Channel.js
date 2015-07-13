// module Signal.Channel

exports.channelP =
  function channelP(constant) {
    return function(v) {
      return function() {
        return constant(v);
      };
    };
  };

exports.sendP =
  function sendP(chan, v) {
    return function(v) {
      return function() {
        chan.set(v);
      };
    };
  };

exports.subscribe =
  function subscribe(chan) {
    return chan;
  };
