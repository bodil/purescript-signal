module Signal.Eff
  ( signalEff
  ) where

import Prelude
import Control.Monad.Eff (Eff)
import Signal (Signal)
import Signal.Channel (CHANNEL, Channel, channel, send)

foreign import signalEffP :: forall a b e. (b -> Eff (channel :: CHANNEL | e) (Channel b)) -- channel
                          -> (Channel b -> b -> Eff (channel :: CHANNEL | e) Unit) -- send
                          -> (a -> Eff e b)
                          -> Eff (channel :: CHANNEL | e) (Signal a -> Signal b)

signalEff :: forall a b e. (a -> Eff e b) -> Eff (channel :: CHANNEL | e) (Signal a -> Signal b)
signalEff = signalEffP channel send
