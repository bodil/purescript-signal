module Signal.Effect
  ( mapEffect
  , foldEffect
  ) where

import Prelude

import Effect (Effect)
import Signal (Signal, constant)
import Signal.Channel (Channel, channel, send)

foreign import mapEffectP :: forall a b. (b -> Effect (Channel b)) -- channel
                          -> (Channel b -> b -> Effect Unit) -- send
                          -> (a -> Effect b)
                          -> Effect (Signal a -> Signal b)

-- | Apply an effectful function to signal values and signal the results.
mapEffect :: forall a b . (a -> Effect b) -> Effect (Signal a -> Signal b)
mapEffect = mapEffectP channel send

foreign import foldEffectP :: ∀ a b. (b -> Signal b) -> (a -> b -> Effect b) -> b -> (Signal a) -> Effect (Signal b)

-- |Creates a past dependent signal with an effectful computation. The function 
-- |argument takes the value of  the input signal, and the previous value of the 
-- |output signal, to produce the new value of the output signal wraped inside an 
-- |`Effect` action.
foldEffect :: ∀ a b. (a -> b -> Effect b) -> b -> (Signal a) -> Effect (Signal b)
foldEffect = foldEffectP constant