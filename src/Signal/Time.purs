module Signal.Time
  ( Time()
  , every
  , delay
  , since
  , millisecond
  , now
  , second
  ) where

import Control.Monad.Eff (Eff())
import Control.Timer (Timer())
import Signal (constant, Signal())

type Time = Number

millisecond :: Time
millisecond = 1.0

second :: Time
second = 1000.0

foreign import everyP :: forall c e. (c -> Signal c) -> Time -> Signal Time

-- |Creates a signal which yields the current time (according to `now`) every
-- |given number of milliseconds.
every :: Time -> Signal Time
every = everyP constant

-- |Returns the number of milliseconds since an arbitrary, but constant, time
-- |in the past.
foreign import now :: forall e. Eff (timer :: Timer | e) Time

foreign import delayP :: forall c a. (c -> Signal c) -> Time -> Signal a -> Signal a

-- |Takes a signal and delays its yielded values by a given number of
-- |milliseconds.
delay :: forall a. Time -> Signal a -> Signal a
delay = delayP constant

foreign import sinceP :: forall c a. (c -> Signal c) -> Time -> Signal a -> Signal Boolean

-- |Takes a signal and a time value, and creates a signal which yields `True`
-- |when the input signal yields, then goes back to `False` after the given
-- |number of milliseconds have elapsed, unless the input signal yields again
-- |in the interim.
since :: forall a. Time -> Signal a -> Signal Boolean
since = sinceP constant
