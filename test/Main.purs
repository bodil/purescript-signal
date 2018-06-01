module Test.Main where

import Prelude

import Data.Either (Either(..), either)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, forkAff, makeAff, nonCanceler, runAff)
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Effect.Exception (error)
import Signal ((~>), get, runSignal, filterMap, filter, foldp, (~), (<~), dropRepeats, sampleOn, constant, mergeMany, flatten)
import Signal.Aff (mapAff)
import Signal.Channel (subscribe, send, channel)
import Signal.Effect (foldEffect, mapEffect)
import Signal.Time (since, delay, every, debounce)
import Test.Signal (expect, expectFn, incAff, incEff, tick)
import Test.Unit (test, timeout)
import Test.Unit.Main (exit, runTestWith)
import Test.Unit.Output.Fancy (runTest)

runAndExit :: Aff Unit -> Effect Unit
runAndExit e = do
  _ <- runAff (either errorHandler successHandler) e
  pure unit
  where errorHandler _ = exit 1
        successHandler _ = exit 0

main :: Effect Unit
main = runAndExit $ runTestWith runTest do

  test "subscribe to constant must yield once" do
    expect 1 (constant "lol") ["lol"]

  test "merge two constants yields first constant" do
    expect 1 (constant "foo" <> constant "bar") ["foo"]

  test "mergeMany a list of constants yields first constant" do
    let sig = fromMaybe (constant "nope")
              (mergeMany [constant "foo", constant "bar", constant "gazonk"])
    expect 1 sig ["foo"]

  test "map function over signal" do
    expect 50 (tick 1 1 [1, 2, 3] ~> \x -> x * 2) [2, 4, 6]

  test "map effectful function over signal" do
    signalConverter <- liftEffect $ mapEffect incEff
    expect 50 (signalConverter $ tick 1 1 [1, 2, 3]) [2, 3, 4]

  test "map asynchronous effect over signal" do
    signalConverter <- liftEffect $ mapAff incAff
    expect 150 (signalConverter $ tick 1 1 [1, 2, 3]) [Nothing, Just 2, Just 3, Just 4]

  test "sum up values with foldEffect" do
    foldEff <- liftEffect $ foldEffect (\a b -> pure (a + b)) 0 $ tick 1 1 [1, 2, 3, 4, 5]
    expect 50 foldEff [1, 3, 6, 10, 15]    

  test "sampleOn samples values from sig2 when sig1 changes" do
    expect 150 (sampleOn (every 40.0) $ tick 10 20 [1, 2, 3, 4, 5, 6]) [1, 3, 5, 6]

  test "dropRepeats only yields when value is /= previous" do
    expect 50 (dropRepeats $ tick 1 1 [1, 1, 2, 2, 1, 3, 3]) [1, 2, 1, 3]

  test "zip with Tuple yields a tuple of both signals" do
    expect 50 (Tuple <~ (tick 2 4 [1, 2, 3]) ~ (tick 4 4 [1, 2, 3]))
      [Tuple 1 1, Tuple 2 1, Tuple 2 2, Tuple 3 2, Tuple 3 3]

  test "sum up values with foldp" do
    expect 50 (foldp (+) 0 $ tick 1 1 [1, 2, 3, 4, 5]) [1, 3, 6, 10, 15]

  test "filter values with filter" do
    expect 50 (filter (\n -> n < 5) 0 $ tick 1 1 [5, 3, 8, 4]) [0, 3, 4]

  test "filter Maybe values with filterMap" do
    expect 50 (filterMap (\n -> if n < 5 then Just n else Nothing)
                 0 $ tick 1 1 [5, 3, 8, 4]) [0, 3, 4]

  test "flatten flattens values" do
    expect 50 (flatten (tick 10 1 [[1, 2], [3, 4], [], [5, 6, 7]]) 0)
      [1, 2, 3, 4, 5, 6, 7]
    expect 50 (flatten (tick 10 1 [[], [1, 2], [3, 4], [], [5, 6, 7]]) 0)
      [0, 1, 2, 3, 4, 5, 6, 7]

  test "channel subscriptions yield when we send to the channel" do
    timeout 50 $ do
      chan <- liftEffect $ channel 1
      liftEffect $ runSignal $ tick 1 1 [2, 3, 4] ~> send chan
      expectFn (subscribe chan) [2, 3, 4]

  test "delayed signal yields same values" do
    expect 50 (delay 40.0 $ tick 1 1 [1, 2, 3, 4, 5]) [1, 2, 3, 4, 5]

  test "since yields true only once for multiple yields, then false" do
    expect 25 (since 10.0 $ tick 1 1 [1, 2, 3]) [false, true, false]

  test "debounce yields only the most recent value in a series shorter than the interval" do
    chan <- liftEffect $ channel 0
    let sig = debounce 10.0 $ subscribe chan
        send' = liftEffect <<< send chan

    _ <- forkAff $ expect 100 sig [0,2,4]
    wait 20.0
    send' 1
    wait 5.0
    send' 2
    wait 20.0
    send' 3
    wait 5.0
    send' 4
    wait 20.0

  test "get gets the current value" do
    let sig = constant "example"
    makeAff $ \resolve -> do
      val <- liftEffect $ get sig
      if (val == "example")
        then resolve $ Right unit
        else resolve $ Left $ error ("Expected get sig to return \"example\" but got " <> val)
      pure nonCanceler

wait :: Number -> Aff Unit
wait t = do
  Aff.delay $ Milliseconds t
  pure unit
