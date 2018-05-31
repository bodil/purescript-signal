module Test.Signal
  ( expect
  , expectFn
  , tick
  ) where

import Prelude
import Effect.Aff (makeAff, nonCanceler)
import Effect.Exception (error)
import Effect.Ref (Ref, write, read, new)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn4, runFn4)
import Data.List (List(..), fromFoldable, toUnfoldable)
import Signal (Signal, constant, (~>), runSignal)
import Test.Unit (Test, timeout)


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
                  -- write remaining (toUnfoldable xs)
                  write (toUnfoldable xs) remaining 
          Nil -> resolve $ Left $ error "unexpected emptiness"
  runSignal $ sig ~> getNext
  pure nonCanceler

expect :: forall a. Eq a => Show a => Int -> Signal a -> Array a -> Test
expect time sig vals = timeout time $ expectFn sig vals

foreign import tickP :: forall a c. Fn4 (c -> Signal c) Int Int (Array a) (Signal a)

tick :: forall a. Int -> Int -> Array a -> Signal a
tick = runFn4 tickP constant
