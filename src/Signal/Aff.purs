module Signal.Aff
  ( mapAff
  ) where

import Prelude

import Data.Either (Either, either)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff, Error, runAff_)
import Signal (Signal)
import Signal.Channel (Channel, channel, send)

-- | Apply an async effectful function to signal values and signal the results.
-- The output signal is Nothing before the first value is processed.
mapAff :: forall a b. (a -> Aff b) -> Effect (Signal a -> Signal (Maybe b))
mapAff action = mapAffP runAff_ mkChannel sendEither action

mkChannel :: forall b. Effect (Channel (Maybe b))
mkChannel = channel Nothing

sendEither :: forall b. Channel (Maybe b) -> Either Error b -> Effect Unit
sendEither chan = either (const $ pure unit) (Just >>> send chan)

foreign import mapAffP :: forall a b. ((Either Error b -> Effect Unit) -> Aff b -> Effect Unit) -- runAff_
                          -> Effect (Channel (Maybe b)) -- mkChannel
                          -> (Channel (Maybe b) -> Either Error b -> Effect Unit) -- sendEither
                          -> (a -> Aff b)
                          -> Effect (Signal a -> Signal (Maybe b))
