// module Signal.Time

function now() {
  var perf = typeof performance !== 'undefined' ? performance : null,
      proc = typeof process !== 'undefined' ? process : null;
  return (
    perf && (perf.now || perf.webkitNow || perf.msNow || perf.oNow || perf.mozNow) ||
    (proc && proc.hrtime && function() {
      var t = proc.hrtime();
      return (t[0] * 1e9 + t[1]) / 1e6;
    }) ||
    Date.now
  ).call(perf);
};

exports.now = now;

exports.everyP = function everyP(constant) {
  return function(t) {
    var out = constant(now());
    setInterval(function() {
      out.set(now());
    }, t);
    return out;
  };
};

exports.delayP = function delayP(constant) {
  return function(t) {
    return function(sig) {
      var out = constant(sig.get());
      var first = true;
      sig.subscribe(function(val) {
        if (first) {
          first = false;
        } else {
          setTimeout(function() {
            out.set(val);
          }, t);
        }
      });
      return out;
    }
  };
};

exports.sinceP = function sinceP(constant) {
  return function(t) {
    return function(sig) {
      var out = constant(false);
      var first = true;
      var timer = undefined;
      var tick = function() {
        out.set(false);
        timer = undefined;
      };
      sig.subscribe(function() {
        if (first) {
          first = false;
          return;
        }
        if (timer === undefined) {
          out.set(true);
          timer = setTimeout(tick, t);
        } else {
          clearTimeout(timer);
          timer = setTimeout(tick, t);
        }
      });
      return out;
    }
  };
};
