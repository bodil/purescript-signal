module Signal.Time
  ( Time(..)
  , every
  , millisecond
  , now
  , second
  ) where

import Control.Monad.Eff (Eff(..))

import Signal (constant, Signal(..))
import DOM (DOM(..))

type Time = Number

millisecond :: Time
millisecond = 1

second :: Time
second = 1000

foreign import everyP """
  function everyP(constant) {
  return function(t) {
    var out = constant(now());
    setInterval(function() {
      out.set(now());
    }, t);
    return out;
  };}""" :: forall c. (c -> Signal c) -> Time -> Signal Time

every = everyP constant

foreign import delayP """
  function delayP(contant) {
  return function(ms) {
  return function(sig) {
  return function() {
    var out = constant(sig.get());
    sig.clear();
    sig.subscribe(function(val) {
      setTimeout(function() {
        out.set(val);
      }, ms);
    });
    return out;
  };};};}""" :: forall e c. (c -> Signal c) -> Time -> Signal c -> Eff (dom :: DOM | e) (Signal c)

delay = delayP constant

foreign import onceP """
  function onceP(constant) {
  return function(sig) {
  return function() {
    var out = constant(sig.get());
    sig.subscribe(function(val) {
      out.set(val);
      sig.clear();
    });
    return out;
  };};}""" :: forall e c. (c -> Signal c) -> Signal c -> Eff (dom :: DOM | e) (Signal c)

once = onceP constant

-- |Returns the number of milliseconds since an arbitrary, but constant, time in the past.
foreign import now """
  function now() {
    var perf = typeof performance !== 'undefined' ? performance : null;
    return (
      perf && (perf.now || perf.webkitNow || perf.msNow || perf.oNow || perf.mozNow) ||
      (process && process.hrtime && function() {
        var t = process.hrtime();
        return (t[0] * 1e9 + t[1]) / 1e6;
      }) ||
      Date.now
    ).call(perf);
  }""" :: forall e. Eff (dom :: DOM | e) Time
