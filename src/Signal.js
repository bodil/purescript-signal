// module Signal

function make(initial) {
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

exports.constant = make;

exports.mapSig = function(fun) {
  return function(sig) {
    var out = make(fun(sig.get()));
    sig.subscribe(function(val) { out.set(fun(val)); });
    return out;
  };
};


exports.applySig = function(fun) {
  return function(sig) {
    var out = make(fun.get()(sig.get()));
    var produce = function() { out.set(fun.get()(sig.get())); };
    fun.subscribe(produce);
    sig.subscribe(produce);
    return out;
  };
};

exports.merge = function(sig1) {
  return function(sig2) {
    var out = make(sig1.get());
    sig2.subscribe(out.set);
    sig1.subscribe(out.set);
    return out;
  };
};

exports.foldp = function(fun) {
  return function(seed) {
    return function(sig) {
      var acc = seed;
      var out = make(acc);
      sig.subscribe(function(val) {
        acc = fun(val)(acc);
        out.set(acc);
      });
      return out;
    };
  };
};

exports.sampleOn = function(sig1) {
  return function(sig2) {
    var out = make(sig2.get());
    sig1.subscribe(function() {
      out.set(sig2.get());
    });
    return out;
  };
};

exports.dropRepeats = function(eq) {
  return function(sig) {
    var val = sig.get();
    var out = make(val);
    sig.subscribe(function(newval) {
      if (!eq["eq"](val)(newval)) {
        val = newval;
        out.set(val);
      }
    });
    return out;
  };
};

exports["dropRepeats'"] = function(sig) {
  var val = sig.get();
  var out = make(val);
  sig.subscribe(function(newval) {
    if (val !== newval) {
      val = newval;
      out.set(val);
    }
  });
  return out;
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

exports.unwrap = function(sig) {
  return function() {
    var out = make(sig.get()());
    sig.subscribe(function(val) { out.set(val()); });
    return out;
  };
};

exports.filter = function(fn) {
  return function(seed) {
    return function(sig) {
      var out = make(fn(sig.get()) ? sig.get() : seed);
      sig.subscribe(function(val) { if (fn(val)) out.set(val); });
      return out;
    };
  };
};

exports.flattenArray = function(sig) {
  return function(seed) {
    var first = sig.get().slice();
    if (first.length > 0) {
      seed = first[0];
    } else {
      first = null;
    }
    var out = make(seed);
    var feed = function(items) { items.forEach(out.set); };
    setTimeout(function() { sig.subscribe(function(val) {
      if (first === null) {
        feed(val);
      } else {
        feed(first.slice(1));
        first = null;
      }
    }); }, 0);
    return out;
  };
};
