module Signal.Channel
  ( channel
  , send
  , subscribe
  , Channel()
  , Chan()
  ) where

import Control.Monad.Eff (Eff)
import Prelude (Unit)

import Signal (constant, Signal)

foreign import data Channel :: * -> *
foreign import data Chan :: !

foreign import channelP :: forall a c e. (c -> Signal c) -> a -> Eff (chan :: Chan | e) (Channel a)

-- |Creates a channel, which allows you to feed arbitrary values into a signal.
channel :: forall a e. a -> Eff (chan :: Chan | e) (Channel a)
channel = channelP constant

foreign import sendP :: forall a e. (Channel a) -> a -> Eff (chan :: Chan | e) Unit

-- |Sends a value to a given channel.
send :: forall a e. Channel a -> a -> Eff (chan :: Chan | e) Unit
send = sendP

-- |Takes a channel and returns a signal of the values sent to it.
foreign import subscribe :: forall a. Channel a -> Signal a
