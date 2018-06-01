module Signal.Effect
  ( mapEffect
  ) where

import Prelude

import Effect (Effect)
import Signal (Signal)
import Signal.Channel (Channel, channel, send)

-- | Apply an effectful function to signal values and signal the results.
foreign import mapEffectP :: forall a b. (b -> Effect (Channel b)) -- channel
                          -> (Channel b -> b -> Effect Unit) -- send
                          -> (a -> Effect b)
                          -> Effect (Signal a -> Signal b)

mapEffect :: forall a b . (a -> Effect b) -> Effect (Signal a -> Signal b)
mapEffect = mapEffectP channel send
