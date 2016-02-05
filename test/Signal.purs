module Test.Signal
  ( expect
  , expectFn
  , tick
  ) where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Ref (REF, writeRef, readRef, newRef)
import Data.Function (Fn4, runFn4)
import Data.List (List(..), toList, fromList)
import Prelude (class Show, class Eq, Unit, bind, ($), show, (++), (/=))
import Signal (Signal, constant, (~>), runSignal)
import Test.Unit (Timer, Assertion, TestResult, testFn, timeout, success, failure)

expectFn :: forall e a. (Eq a, Show a) => Signal a -> Array a -> (TestResult -> Eff (ref :: REF | e) Unit) -> Eff (ref :: REF | e) Unit
expectFn sig vals done = do
  remaining <- newRef vals
  let getNext val = do
        nextValArray <- readRef remaining
        let nextVals = toList nextValArray
        case nextVals of
          Cons x xs -> do
            if x /= val then done $ failure $ "expected " ++ show x ++ " but got " ++ show val
              else case xs of
                Nil -> done success
                _ -> writeRef remaining (fromList xs)
          Nil -> done $ failure "unexpected emptiness"
  runSignal $ sig ~> getNext

expect :: forall e a. (Eq a, Show a) => Int -> Signal a -> Array a -> Assertion (timer :: Timer, ref :: REF | e)
expect time sig vals = timeout time $ testFn $ expectFn sig vals

foreign import tickP :: forall a c. Fn4 (c -> Signal c) Int Int (Array a) (Signal a)

tick :: forall a. Int -> Int -> Array a -> Signal a
tick = runFn4 tickP constant
