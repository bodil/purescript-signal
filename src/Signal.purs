module Signal
  ( Signal()
  , constant
  , mapSig
  , applySig
  , merge
  , mergeMany
  , foldp
  , sampleOn
  , distinct
  , distinct'
  , zip
  , runSignal
  , unwrap
  , keepIf
  , (<~)
  , (~>)
  , (~)
  ) where

import Control.Monad.Eff (Eff())
import Prelude ((<$>), (<*>), flip, Unit(), Eq, Semigroup, Functor, Applicative, Apply)
import Data.Foldable (foldl, Foldable)
import Data.Maybe (Maybe(..))

foreign import data Signal :: * -> *

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

foldp :: forall a b. (a -> b -> b) -> b -> Signal a -> Signal b
foldp = foldpP constant

foreign import sampleOnP :: forall a b c. (c -> Signal c) -> (Signal a) -> (Signal b) -> (Signal b)

sampleOn :: forall a b. Signal a -> Signal b -> Signal b
sampleOn = sampleOnP constant

foreign import distinctP :: forall a c. (Eq a) => (c -> Signal c) -> Signal a -> Signal a

distinct :: forall a. (Eq a) => Signal a -> Signal a
distinct = distinctP constant

foreign import distinctRefP :: forall a c. (c -> Signal c) -> (Signal a) -> (Signal a)

distinct' :: forall a. Signal a -> Signal a
distinct' = distinctRefP constant

zip :: forall a b c. (a -> b -> c) -> Signal a -> Signal b -> Signal c
zip = map2

foreign import runSignal :: forall e. Signal (Eff e Unit) -> Eff e Unit

foreign import unwrapP :: forall e a c. (c -> Signal c) -> (Signal (Eff e a)) -> (Eff e (Signal a))

unwrap :: forall a e. Signal (Eff e a) -> Eff e (Signal a)
unwrap = unwrapP constant

foreign import keepIfP :: forall a c. (c -> Signal c) -> (a -> Boolean) -> a -> (Signal a) -> (Signal a)

keepIf :: forall a. (a -> Boolean) -> a -> Signal a -> Signal a
keepIf = keepIfP constant

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
