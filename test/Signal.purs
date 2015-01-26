module Test.Signal
  ( expect
  , expectFn
  , tick
  ) where

import Control.Monad.Eff
import Control.Monad.Eff.Ref
import Control.Timer(Timer(..))
import Data.Function
import Signal
import Test.Unit

expectFn :: forall e a. (Eq a, Show a) => Signal a -> [a] -> (TestResult -> Eff (ref :: Ref | e) Unit) -> Eff (ref :: Ref | e) Unit
expectFn sig vals done = do
  remaining <- newRef vals
  let getNext val = do
        nextVals <- readRef remaining
        case nextVals of
          (x : xs) -> do
            if x /= val then done $ failure $ "expected " ++ show x ++ " but got " ++ show val
              else case xs of
                [] -> done success
                _ -> writeRef remaining xs
  runSignal $ sig ~> getNext

expect :: forall e a. (Eq a, Show a) => Number -> Signal a -> [a] -> Assertion (timer :: Timer, ref :: Ref | e)
expect time sig vals = timeout time $ testFn $ expectFn sig vals

foreign import tickP """
  function tickP(constant, initial, interval, values) {
    var vals = values.slice();
    var out = constant(vals.shift());
    if (vals.length) {
      setTimeout(function pop() {
        out.set(vals.shift());
        if (vals.length) {
          setTimeout(pop, interval);
        }
      }, initial);
    }
    return out;
  }""" :: forall a c. Fn4 (c -> Signal c) Number Number [a] (Signal a)
tick = runFn4 tickP constant
