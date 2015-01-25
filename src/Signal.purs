module Signal
  ( Signal(..)
  , constant
  , map
  , applySig
  , merge
  , foldp
  , sampleOn
  , distinct
  , distinct'
  , zip
  , runSignal
  , unwrap
  , (<~)
  , (~>)
  , (~)
  ) where

import Control.Monad.Eff
import Data.Function

foreign import data Signal :: * -> *

foreign import constant """
  function constant(initial) {
    var subs = [];
    var val = initial;
    var sig = {
      subscribe: function(sub) {
        subs.push(sub);
        sub(val);
      },
      get: function() { return val; },
      set: function(newval) {
        val = newval;
        subs.forEach(function(sub) { sub(newval); });
      }
    };
    return sig;
  }""" :: forall a. a -> Signal a

foreign import mapP """
  function mapP(constant, fun, sig) {
    var out = constant(fun(sig.get()));
    sig.subscribe(function(val) { out.set(fun(val)); });
    return out;
  }""" :: forall a b c. Fn3 (c -> Signal c) (a -> b) (Signal a) (Signal b)

map :: forall a b. (a -> b) -> Signal a -> Signal b
map = runFn3 mapP constant

foreign import applySigP """
  function applySigP(constant, fun, sig) {
    var out = constant(fun.get()(sig.get()));
    var produce = function() { out.set(fun.get()(sig.get())); };
    fun.subscribe(produce);
    sig.subscribe(produce);
    return out;
  }""" :: forall a b c. Fn3 (c -> Signal c) (Signal (a -> b)) (Signal a) (Signal b)

applySig :: forall a b. Signal (a -> b) -> Signal a -> Signal b
applySig = runFn3 applySigP constant

foreign import mergeP """
  function mergeP(constant, sig1, sig2) {
    var out = constant(sig1.get());
    sig1.subscribe(out.set);
    sig2.subscribe(out.set);
    return out;
  }""" :: forall a c. Fn3 (c -> Signal c) (Signal a) (Signal a) (Signal a)

merge :: forall a. Signal a -> Signal a -> Signal a
merge = runFn3 mergeP constant

foreign import foldpP """
  function foldpP(constant, fun, seed, sig) {
    var acc = seed;
    var out = constant(acc);
    sig.subscribe(function(val) {
      acc = fun(val)(acc);
      out.set(acc);
    });
    return out;
  }""" :: forall a b c. Fn4 (c -> Signal c) (a -> b -> b) b (Signal a) (Signal b)

foldp :: forall a b. (a -> b -> b) -> b -> Signal a -> Signal b
foldp = runFn4 foldpP constant

foreign import sampleOnP """
  function sampleOnP(constant, sig1, sig2) {
    var out = constant(sig2.get());
    sig1.subscribe(function() {
      out.set(sig2.get());
    });
    return out;
  }""" :: forall a b c. Fn3 (c -> Signal c) (Signal a) (Signal b) (Signal b)

sampleOn :: forall a b. Signal a -> Signal b -> Signal b
sampleOn = runFn3 sampleOnP constant

foreign import distinctP """
  function distinctP(eq) {
  return function(constant) {
  return function(sig) {
    var val = sig.get();
    var out = constant(val);
    sig.subscribe(function(newval) {
      if (eq['/='](val)(newval)) {
        val = newval;
        out.set(val);
      }
    });
    return out;
  };};}""" :: forall a c. (Eq a) => (c -> Signal c) -> Signal a -> Signal a

distinct :: forall a. (Eq a) => Signal a -> Signal a
distinct = distinctP constant

foreign import distinctRefP """
  function distinctRefP(constant, sig) {
    var val = sig.get();
    var out = constant(val);
    sig.subscribe(function(newval) {
      if (val !== newval) {
        val = newval;
        out.set(val);
      }
    });
    return out;
  }""" :: forall a c. Fn2 (c -> Signal c) (Signal a) (Signal a)

distinct' :: forall a. Signal a -> Signal a
distinct' = runFn2 distinctRefP constant

foreign import zipP """
  function zipP(constant, f, sig1, sig2) {
    var val1 = sig1.get(), val2 = sig2.get();
    var out = constant(f(val1)(val2));
    sig1.subscribe(function(v) {
      val1 = v;
      out.set(f(val1)(val2));
    });
    sig2.subscribe(function(v) {
      val2 = v;
      out.set(f(val1)(val2));
    });
    return out;
  }""" :: forall a b c d. Fn4 (d -> Signal d) (a -> b -> c) (Signal a) (Signal b) (Signal c)

zip :: forall a b c. (a -> b -> c) -> Signal a -> Signal b -> Signal c
zip f a b = runFn4 zipP constant f a b

foreign import runSignal """
  function runSignal(sig) {
    return function() {
      sig.subscribe(function(val) {
        val();
      });
      return {};
    };
  }""" :: forall e. Signal (Eff e Unit) -> Eff e Unit

foreign import unwrapP """
  function unwrapP(constant, sig) {
    return function() {
      var out = constant(sig.get()());
      sig.subscribe(function(val) { out.set(val()); });
      return out;
    };
  }""" :: forall e a c. Fn2 (c -> Signal c) (Signal (Eff e a)) (Eff e (Signal a))

unwrap :: forall a e. Signal (Eff e a) -> Eff e (Signal a)
unwrap = runFn2 unwrapP constant

instance functorSignal :: Functor Signal where
  (<$>) = map

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

map2 :: forall a b c. (a -> b -> c) -> Signal a -> Signal b -> Signal c
map2 f a b = f <~ a ~ b

map3 :: forall a b c d. (a -> b -> c -> d) -> Signal a -> Signal b -> Signal c -> Signal d
map3 f a b c = f <~ a ~ b ~ c

map4 :: forall a b c d e. (a -> b -> c -> d -> e) -> Signal a -> Signal b -> Signal c -> Signal d -> Signal e
map4 f a b c d = f <~ a ~ b ~ c ~ d

map5 :: forall a b c d e f. (a -> b -> c -> d -> e -> f) -> Signal a -> Signal b -> Signal c -> Signal d -> Signal e -> Signal f
map5 f a b c d e = f <~ a ~ b ~ c ~ d ~ e
