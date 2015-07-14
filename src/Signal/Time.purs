module Signal.Time
  ( Time()
  , every
  , delay
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

every :: Time -> Signal Time
every = everyP constant

-- |Returns the number of milliseconds since an arbitrary, but constant, time in the past.
foreign import now :: forall e. Eff (timer :: Timer | e) Time

foreign import delayP :: forall c a. (c -> Signal c) -> Time -> Signal a -> Signal a

-- |Takes a signal and delays its yielded values by a given number of
-- |milliseconds.
delay :: forall a. Time -> Signal a -> Signal a
delay = delayP constant
