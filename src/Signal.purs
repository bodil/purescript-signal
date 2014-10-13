module Signal
  ( Signal(..)
  , constant
  , lift
  , applySig
  , merge
  , foldp
  , sampleOn
  , distinct
  , runSignal
  , unwrap
  , (<~)
  , (~>)
  , (~)
  ) where

import Control.Monad.Eff

foreign import data Signal :: * -> *

foreign import constant """
  function constant(initial) {
    var subs = [];
    var val = initial;
    var sig = {
      subscribe: function(sub) {
        subs.push(sub);
      },
      clear: function() {
        subs = [];
      },
      get: function() { return val; },
      set: function(newval) {
        val = newval;
        subs.forEach(function(sub) { sub(newval); });
      }
    };
    return sig;
  }""" :: forall a. a -> Signal a

foreign import liftP """
  function liftP(constant) {
  return function(fun) {
  return function(sig) {
    var out = constant(fun(sig.get()));
    sig.subscribe(function(val) { out.set(fun(val)); });
    return out;
  };};}""" :: forall a b c. (c -> Signal c) -> (a -> b) -> Signal a -> Signal b

lift = liftP constant

foreign import applySigP """
  function applySigP(constant) {
  return function(fun) {
  return function(sig) {
    var out = constant(fun.get()(sig.get()));
    var produce = function() { out.set(fun.get()(sig.get())); };
    fun.subscribe(produce);
    sig.subscribe(produce);
    return out;
  };};}""" :: forall a b c. (c -> Signal c) -> Signal (a -> b) -> Signal a -> Signal b

applySig = applySigP constant

foreign import mergeP """
  function mergeP(consant) {
  return function(sig1) {
  return function(sig2) {
    var out = constant(sig1.get());
    sig1.subscribe(out.set);
    sig2.subscribe(out.set);
    return out;
  };};}""" :: forall a c. (c -> Signal c) -> Signal a -> Signal a -> Signal a

merge = mergeP constant

foreign import foldpP """
  function foldpP(constant) {
  return function(fun) {
  return function(seed) {
  return function(sig) {
    var acc = fun(sig.get())(seed);
    var out = constant(acc);
    sig.subscribe(function(val) {
      acc = fun(val)(acc);
      out.set(acc);
    });
    return out;
  };};};}""" :: forall a b c. (c -> Signal c) -> (a -> b -> b) -> b -> Signal a -> Signal b

foldp = foldpP constant

foreign import sampleOnP """
  function sampleOnP(constant) {
  return function(sig1) {
  return function(sig2) {
    var out = constant(sig2.get());
    sig1.subscribe(function() {
      out.set(sig2.get());
    });
    return out;
  };};}""" :: forall a b c. (c -> Signal c) -> Signal a -> Signal b -> Signal b

sampleOn = sampleOnP constant

foreign import distinctP """
  function distinctP(constant) {
  return function(eq) {
  return function(sig) {
    var val = sig.get();
    var out = constant(val);
    sig.subscribe(function(newval) {
      if (eq['/='](val, newval)) {
        val = newval;
        out.set(val);
      }
    });
    return out;
  };};}""" :: forall a c. (Eq a) => (c -> Signal c) -> Signal a -> Signal a

distinct :: forall a. (Eq a) => Signal a -> Signal a
distinct = distinctP constant

foreign import runSignal """
  function runSignal(sig) {
  return function() {
    sig.subscribe(function(val) {
      val();
    });
    return {};
  };}""" :: forall e. Signal (Eff e Unit) -> Eff e Unit

foreign import unwrapP """
  function unwrapP(constant) {
  return function(sig) {
  return function() {
    var out = constant(sig.get()());
    sig.subscribe(function(val) { out.set(val()); });
    return out;
  };};}""" :: forall e a c. (c -> Signal c) -> Signal (Eff e a) -> Eff e (Signal a)

unwrap = unwrapP constant

instance functorSignal :: Functor Signal where
  (<$>) = lift

instance applySignal :: Apply Signal where
  (<*>) = applySig

instance applicativeSignal :: Applicative Signal where
  pure = constant

instance semigroupSignal :: Semigroup (Signal a) where
  (<>) = merge

infixl 4 <~
(<~) :: forall f a b. (Functor f) => (a -> b) -> f a -> f b
(<~) = (<$>)

infixl 4 ~>
(~>) :: forall f a b. (Functor f) => f a -> (a -> b) -> f b
(~>) = flip (<$>)

infixl 4 ~
(~) :: forall f a b. (Apply f) => f (a -> b) -> f a -> f b
(~) = (<*>)
