module Signal.Time
  ( Time()
  , every
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

foreign import everyP :: forall c e. (c -> Signal c) -> Eff (timer :: Timer | e) Time -> Time -> Signal Time

every :: Time -> Signal Time
every = everyP constant now

-- |Returns the number of milliseconds since an arbitrary, but constant, time in the past.
foreign import now :: forall e. Eff (timer :: Timer | e) Time
