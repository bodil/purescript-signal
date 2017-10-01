module Signal.Eff
  ( mapEff
  ) where

import Prelude
import Control.Monad.Eff (Eff)
import Signal (Signal)
import Signal.Channel (CHANNEL, Channel, channel, send)

-- | Apply an effectful function to signal values and signal the results.
foreign import mapEffP :: forall a b e. (b -> Eff (channel :: CHANNEL | e) (Channel b)) -- channel
                          -> (Channel b -> b -> Eff (channel :: CHANNEL | e) Unit) -- send
                          -> (a -> Eff e b)
                          -> Eff (channel :: CHANNEL | e) (Signal a -> Signal b)

mapEff :: forall a b e. (a -> Eff e b) -> Eff (channel :: CHANNEL | e) (Signal a -> Signal b)
mapEff = mapEffP channel send
