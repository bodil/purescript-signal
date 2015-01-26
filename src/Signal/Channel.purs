module Signal.Channel
  ( channel
  , send
  , subscribe
  , Channel(..)
  , Chan(..)
  ) where

import Control.Monad.Eff
import Data.Function
import Signal

foreign import data Channel :: * -> *
foreign import data Chan :: !

foreign import channelP """
  function channelP(constant, v) {
    return function() {
      return constant(v);
    };
  }""" :: forall a c e. Fn2 (c -> Signal c) a (Eff (chan :: Chan | e) (Channel a))

channel :: forall a e. a -> Eff (chan :: Chan | e) (Channel a)
channel = runFn2 channelP constant

foreign import sendP """
  function sendP(chan, v) {
    return function() {
      chan.set(v);
    };
  }""" :: forall a e. Fn2 (Channel a) a (Eff (chan :: Chan | e) Unit)

send :: forall a e. Channel a -> a -> Eff (chan :: Chan | e) Unit
send = runFn2 sendP

foreign import subscribe """
  function subscribe(chan) {
    return chan;
  }""" :: forall a. Channel a -> Signal a
