module Test.Signal
  ( expect
  , tick
  ) where

import Control.Monad.Eff.Ref
import Control.Timer(Timer(..))
import Data.Function
import Signal
import Test.Unit

expect :: forall e a. (Eq a, Show a) => Number -> Signal a -> [a] -> Assertion (timer :: Timer, ref :: Ref | e)
expect time sig vals = timeout time $ testFn \done -> do
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
