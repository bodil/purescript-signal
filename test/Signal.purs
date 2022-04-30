module Test.Signal
  ( expect
  , expectFn
  , incAff
  , incEff
  , tick
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Function.Uncurried (Fn4, runFn4)
import Data.List (List(..), fromFoldable, toUnfoldable)
import Effect (Effect)
import Effect.Aff (Aff, Canceler, Error, makeAff, nonCanceler)
import Effect.Exception (error)
import Effect.Ref (Ref, write, read, new)
import Signal (Signal, constant, (~>), runSignal)
import Test.TestUtils (Test, timeout)


type Tail a = Ref (Array a)

expectFn :: forall a. Eq a => Show a => Signal a -> Array a -> Test
expectFn sig vals = makeAff \resolve -> do
  remaining <- new vals
  let getNext val = do
        nextValArray <- read remaining
        let nextVals = fromFoldable nextValArray
        case nextVals of
          Cons x xs -> do
            if x /= val then resolve $ Left $ error $ "expected " <> show x <> " but got " <> show val
              else case xs of
                Nil -> resolve $ Right unit
                _ ->
                  write (toUnfoldable xs) remaining 
          Nil -> resolve $ Left $ error "unexpected emptiness"
  runSignal $ sig ~> getNext
  pure nonCanceler

expect :: forall a. Eq a => Show a => Int -> Signal a -> Array a -> Test
expect time sig vals = timeout time $ expectFn sig vals

foreign import tickP :: forall a c. Fn4 (c -> Signal c) Int Int (Array a) (Signal a)

tick :: forall a. Int -> Int -> Array a -> Signal a
tick = runFn4 tickP constant

foreign import incEff :: Int -> Effect Int

foreign import incAffP :: (Int -> Either Error Int) -> Int -> (Either Error Int -> Effect Unit) -> Effect Canceler

incAff :: Int -> Aff Int
incAff val = makeAff (incAffP Right val)
