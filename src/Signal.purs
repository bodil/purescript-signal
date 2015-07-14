module Signal
  ( Signal()
  , constant
  , merge
  , mergeMany
  , foldp
  , sampleOn
  , dropRepeats
  , dropRepeats'
  , runSignal
  , unwrap
  , filter
  , filterMap
  , (<~)
  , (~>)
  , (~)
  ) where

import Control.Monad.Eff (Eff())
import Prelude ((<$>), (<*>), flip, Unit(), Eq, Semigroup, Functor, Applicative, Apply)
import Data.Foldable (foldl, Foldable)
import Data.Maybe (Maybe(..), fromMaybe, isJust)

foreign import data Signal :: * -> *

-- |Creates a signal with a constant value.
foreign import constant :: forall a. a -> Signal a

foreign import mapSigP :: forall a b c. (c -> Signal c) -> (a -> b) -> (Signal a) -> (Signal b)

mapSig :: forall a b. (a -> b) -> Signal a -> Signal b
mapSig = mapSigP constant

foreign import applySigP :: forall a b c. (c -> Signal c) -> (Signal (a -> b)) -> (Signal a) -> (Signal b)

applySig :: forall a b. Signal (a -> b) -> Signal a -> Signal b
applySig = applySigP constant

foreign import mergeP :: forall a c. (c -> Signal c) -> (Signal a) -> (Signal a) -> (Signal a)

-- |Merge two signals, returning a new signal which will yield a value
-- |whenever either of the input signals yield. Its initial value will be
-- |that of the first signal.
merge :: forall a. Signal a -> Signal a -> Signal a
merge = mergeP constant

-- |Merge all signals inside a `Foldable`, returning a `Maybe` which will
-- |either contain the resulting signal, or `Nothing` if the `Foldable`
-- |was empty.
mergeMany :: forall f a. (Functor f, Foldable f) => f (Signal a) -> Maybe (Signal a)
mergeMany sigs = foldl mergeMaybe Nothing (Just <$> sigs)
  where mergeMaybe a Nothing = a
        mergeMaybe Nothing a = a
        mergeMaybe (Just a) (Just b) = Just (merge a b)

foreign import foldpP :: forall a b c. (c -> Signal c) -> (a -> b -> b) -> b -> (Signal a) -> (Signal b)

-- |Creates a past dependent signal. The function argument takes the value of
-- |the input signal, and the previous value of the output signal, to produce
-- |the new value of the output signal.
foldp :: forall a b. (a -> b -> b) -> b -> Signal a -> Signal b
foldp = foldpP constant

foreign import sampleOnP :: forall a b c. (c -> Signal c) -> (Signal a) -> (Signal b) -> (Signal b)

-- |Creates a signal which yields the current value of the second signal every
-- |time the first signal yields.
sampleOn :: forall a b. Signal a -> Signal b -> Signal b
sampleOn = sampleOnP constant

foreign import dropRepeatsP :: forall a c. (Eq a) => (c -> Signal c) -> Signal a -> Signal a

-- |Create a signal which only yields values which aren't equal to the previous
-- |value of the input signal.
dropRepeats :: forall a. (Eq a) => Signal a -> Signal a
dropRepeats = dropRepeatsP constant

foreign import dropRepeatsRefP :: forall a c. (c -> Signal c) -> (Signal a) -> (Signal a)

-- |Create a signal which only yields values which aren't equal to the previous
-- |value of the input signal, using JavaScript's `!==` operator to determine
-- |disequality.
dropRepeats' :: forall a. Signal a -> Signal a
dropRepeats' = dropRepeatsRefP constant

-- |Given a signal of effects with no return value, run each effect as it
-- |comes in.
foreign import runSignal :: forall e. Signal (Eff e Unit) -> Eff e Unit

foreign import unwrapP :: forall e a c. (c -> Signal c) -> Signal (Eff e a) -> Eff e (Signal a)

-- |Takes a signal of effects of `a`, and produces an effect which returns a
-- |signal which will take each effect produced by the input signal, run it,
-- |and yield its returned value.
unwrap :: forall a e. Signal (Eff e a) -> Eff e (Signal a)
unwrap = unwrapP constant

foreign import filterP :: forall a c. (c -> Signal c) -> (a -> Boolean) -> a -> (Signal a) -> (Signal a)

-- |Takes a signal and filters out yielded values for which the provided
-- |predicate function returns `false`.
filter :: forall a. (a -> Boolean) -> a -> Signal a -> Signal a
filter = filterP constant

-- |Map a signal over a function which returns a `Maybe`, yielding only the
-- |values inside `Just`s, dropping the `Nothing`s.
filterMap :: forall a b. (a -> Maybe b) -> b -> Signal a -> Signal b
filterMap f def sig = (fromMaybe def) <$> filter isJust (Just def) (f <$> sig)

instance functorSignal :: Functor Signal where
  map = mapSig

instance applySignal :: Apply Signal where
  apply = applySig

instance applicativeSignal :: Applicative Signal where
  pure = constant

instance semigroupSignal :: Semigroup (Signal a) where
  append = merge

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
