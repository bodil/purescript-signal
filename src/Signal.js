// module Signal

exports.constant =
  function constant(initial) {
    var subs = [];
    var val = initial;
    var sig = {
      subscribe: function(sub) {
        subs.push(sub);
        sub(val);
      },
      get: function() { return val; },
      set: function(newval) {
        val = newval;
        subs.forEach(function(sub) { sub(newval); });
      }
    };
    return sig;
  };

exports.mapSigP =
  function mapSigP(constant) {
    return function(fun) {
      return function(sig) {
        var out = constant(fun(sig.get()));
        sig.subscribe(function(val) { out.set(fun(val)); });
        return out;
      };
    };
  };


exports.applySigP =
  function applySigP(constant) {
    return function(fun) {
      return function(sig) {
        var out = constant(fun.get()(sig.get()));
        var produce = function() { out.set(fun.get()(sig.get())); };
        fun.subscribe(produce);
        sig.subscribe(produce);
        return out;
      };
    };
  };

exports.mergeP =
  function mergeP(constant) {
    return function(sig1) {
      return function(sig2) {
        var out = constant(sig1.get());
        sig2.subscribe(out.set);
        sig1.subscribe(out.set);
        return out;
      };
    };
  };

exports.foldpP =
  function foldpP(constant) {
    return function(fun) {
      return function(seed) {
        return function(sig) {
          var acc = seed;
          var out = constant(acc);
          sig.subscribe(function(val) {
            acc = fun(val)(acc);
            out.set(acc);
          });
          return out;
        };
      };
    };
  };

exports.sampleOnP =
  function sampleOnP(constant) {
    return function(sig1) {
      return function(sig2) {
        var out = constant(sig2.get());
        sig1.subscribe(function() {
          out.set(sig2.get());
        });
        return out;
      };
    };
  };

exports.dropRepeatsP =
function dropRepeatsP(eq) {
  return function(constant) {
    return function(sig) {
      var val = sig.get();
      var out = constant(val);
      sig.subscribe(function(newval) {
        if (!eq["eq"](val)(newval)) {
          val = newval;
          out.set(val);
        }
      });
      return out;
    };
  };
};

exports.dropRepeatsRefP =
  function dropRepeatsRefP(constant) {
    return function(sig) {
      var val = sig.get();
      var out = constant(val);
      sig.subscribe(function(newval) {
        if (val !== newval) {
          val = newval;
          out.set(val);
        }
      });
      return out;
    };
  };

exports.runSignal =
  function runSignal(sig) {
    return function() {
      sig.subscribe(function(val) {
        val();
      });
      return {};
    };
  };

exports.unwrapP =
  function unwrapP(constant) {
    return function(sig) {
      return function() {
        var out = constant(sig.get()());
        sig.subscribe(function(val) { out.set(val()); });
        return out;
      };
    };
  };

exports.filterP =
  function keepIfP(constant) {
    return function(fn) {
      return function(seed) {
        return function(sig) {
          var out = constant(fn(sig.get()) ? sig.get() : seed);
          sig.subscribe(function(val) { if (fn(val)) out.set(val); });
          return out;
        };
      };
    };
  };
