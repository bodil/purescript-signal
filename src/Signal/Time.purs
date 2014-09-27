module Signal.Time (
  Time(..),
  millisecond,
  second,
  every,
  now
  ) where

import Control.Monad.Eff
import Signal
import DOM

type Time = Number

millisecond :: Time
millisecond = 1

second :: Time
second = 1000

_constant = constant

foreign import every
  "function every(t) {\
  \  var out = _constant(now());\
  \  setInterval(function() {\
  \    out.set(now());\
  \  }, t);\
  \  return out;\
  \}" :: Time -> Signal Time

-- |Returns the number of milliseconds since an arbitrary, but constant, time in the past.
foreign import now
  "function now() {\
  \  var perf; try { perf = performance; } catch(e) { perf = null; }\
  \  return ((perf && (perf.now ||\
  \                    perf.webkitNow ||\
  \                    perf.msNow ||\
  \                    perf.oNow ||\
  \                    perf.mozNow)) ||\
  \          (process && process.hrtime && function() {\
  \            var t = process.hrtime();\
  \            return (t[0] * 1e9 + t[1]) / 1e6;\
  \          }) ||\
  \          function() { return Date.now(); });\
  \}" :: forall e. Eff (dom :: DOM | e) Time
