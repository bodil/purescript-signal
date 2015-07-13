module Signal.Channel
  ( channel
  , send
  , subscribe
  , Channel()
  , Chan()
  ) where

import Control.Monad.Eff (Eff())
import Prelude (Unit())

import Signal (constant, Signal())

foreign import data Channel :: * -> *
foreign import data Chan :: !

foreign import channelP :: forall a c e. (c -> Signal c) -> a -> Eff (chan :: Chan | e) (Channel a)

channel :: forall a e. a -> Eff (chan :: Chan | e) (Channel a)
channel = channelP constant

foreign import sendP :: forall a e. (Channel a) -> a -> Eff (chan :: Chan | e) Unit

send :: forall a e. Channel a -> a -> Eff (chan :: Chan | e) Unit
send = sendP

foreign import subscribe :: forall a. Channel a -> Signal a
