module Signal where

import Control.Monad.Eff

foreign import data Signal :: * -> *

foreign import constant
  "function constant(initial) {\
  \    var subs = [];\
  \    var val = initial;\
  \    var sig = {\
  \      subscribe: function(sub) {\
  \        subs.push(sub);\
  \      },\
  \      get: function() { return val; },\
  \      set: function(newval) {\
  \        val = newval;\
  \        subs.forEach(function(sub) { sub(newval); });\
  \      }\
  \    };\
  \    return sig;\
  \}" :: forall a. a -> Signal a

foreign import lift
  "function lift(fun) {\
  \  return function(sig) {\
  \    var out = constant(fun(sig.get()));\
  \    sig.subscribe(function(val) { out.set(fun(val)); });\
  \    return out;\
  \  };\
  \}" :: forall a b. (a -> b) -> Signal a -> Signal b

foreign import applySig
  "function applySig(fun) {\
  \  return function(sig) {\
  \    var out = constant(fun.get()(sig.get()));\
  \    var produce = function() { out.set(fun.get()(sig.get())); };\
  \    fun.subscribe(produce);\
  \    sig.subscribe(produce);\
  \    return out;\
  \  };\
  \}" :: forall a b. Signal (a -> b) -> Signal a -> Signal b

foreign import merge
  "function merge(sig1) {\
  \  return function(sig2) {\
  \    var out = constant(sig1.get());\
  \    sig1.subscribe(out.set);\
  \    sig2.subscribe(out.set);\
  \    return out;\
  \  };\
  \}" :: forall a. Signal a -> Signal a -> Signal a

foreign import foldp
  "function foldp(fun) {\
  \  return function(seed) {\
  \    return function(sig) {\
  \      var acc = fun(sig.get())(seed);\
  \      var out = constant(acc);\
  \      sig.subscribe(function(val) {\
  \        acc = fun(val)(acc);\
  \        out.set(acc);\
  \      });\
  \      return out;\
  \    };\
  \  };\
  \}" :: forall a b. (a -> b -> b) -> b -> Signal a -> Signal b

foreign import sampleOn
  "function sampleOn(sig1) {\
  \  return function(sig2) {\
  \    var out = constant(sig2.get());\
  \    sig1.subscribe(function() {\
  \      out.set(sig2.get());\
  \    });\
  \    return out;\
  \  };\
  \}" :: forall a b. Signal a -> Signal b -> Signal b

foreign import distinct
  "function distinct(eq) {\
  \  return function(sig) {\
  \    var val = sig.get();\
  \    var out = constant(val);\
  \    sig.subscribe(function(newval) {\
  \      if (eq['/='](val, newval)) {\
  \        val = newval;\
  \        out.set(val);\
  \      }\
  \    });\
  \    return out;\
  \  };\
  \}" :: forall a. (Eq a) => Signal a -> Signal a

foreign import runSignal
  "function runSignal(sig) {\
  \  return function() {\
  \    sig.subscribe(function(val) {\
  \      val();\
  \    });\
  \    return {};\
  \  };\
  \}" :: forall e. Signal (Eff e Unit) -> Eff e Unit

foreign import unwrap
  "function unwrap(sig) {\
  \  return function() {\
  \    var out = constant(sig.get()());\
  \    sig.subscribe(function(val) { out.set(val()); });\
  \    return out;\
  \  };\
  \}" :: forall e a. Signal (Eff e a) -> Eff e (Signal a)

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
