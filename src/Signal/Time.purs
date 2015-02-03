module Signal.Time
  ( Time(..)
  , every
  , millisecond
  , now
  , second
  ) where

import Control.Monad.Eff (Eff(..))
import Control.Timer (Timer(..))
import Data.Function
import Signal (constant, Signal(..))

type Time = Number

millisecond :: Time
millisecond = 1

second :: Time
second = 1000

foreign import everyP """
  function everyP(constant, now, t) {
    var out = constant(now());
    setInterval(function() {
      out.set(now());
    }, t);
    return out;
  }""" :: forall c e. Fn3 (c -> Signal c) (Eff (timer :: Timer | e) Time) Time (Signal Time)

every :: Time -> Signal Time
every = runFn3 everyP constant now

-- |Returns the number of milliseconds since an arbitrary, but constant, time in the past.
foreign import now """
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
  }""" :: forall e. Eff (timer :: Timer | e) Time
