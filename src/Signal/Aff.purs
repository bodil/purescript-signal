module Signal.Aff
  ( signalAff
  ) where

import Prelude

import Control.Monad.Aff (Aff, runAff_)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (Error)
import Data.Either (Either, either)
import Data.Maybe (Maybe(..))
import Signal (Signal)
import Signal.Channel (CHANNEL, Channel, channel, send)

-- | Apply an async effectful function to signal values and signal the results.
-- The output signal is Nothing before the first value is processed.
signalAff :: forall a b e. (a -> Aff e b) -> Eff (channel :: CHANNEL | e) (Signal a -> Signal (Maybe b))
signalAff action = signalAffP runAff_ mkChannel sendEither action

mkChannel :: forall b e. Eff (channel :: CHANNEL | e) (Channel (Maybe b))
mkChannel = channel Nothing

sendEither :: forall b e. Channel (Maybe b) -> Either Error b -> Eff (channel :: CHANNEL | e) Unit
sendEither chan = either (const $ pure unit) (Just >>> send chan)

foreign import signalAffP :: forall a b e. ((Either Error b -> Eff e Unit) -> Aff e b -> Eff e Unit) -- runAff_
                          -> Eff (channel :: CHANNEL | e) (Channel (Maybe b)) -- mkChannel
                          -> (Channel (Maybe b) -> Either Error b -> Eff (channel :: CHANNEL | e) Unit) -- sendEither
                          -> (a -> Aff e b)
                          -> Eff (channel :: CHANNEL | e) (Signal a -> Signal (Maybe b))
