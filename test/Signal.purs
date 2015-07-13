module Test.Signal
  ( expect
  , expectFn
  , tick
  ) where

import Control.Monad.Eff
import Control.Monad.Eff.Ref
import Data.Function
import Data.List (List(..), toList, fromList)
import Prelude
import Signal
import Test.Unit

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
  runSignal $ sig ~> getNext

expect :: forall e a. (Eq a, Show a) => Int -> Signal a -> Array a -> Assertion (timer :: Timer, ref :: REF | e)
expect time sig vals = timeout time $ testFn $ expectFn sig vals

foreign import tickP :: forall a c. Fn4 (c -> Signal c) Int Int (Array a) (Signal a)
tick = runFn4 tickP constant
