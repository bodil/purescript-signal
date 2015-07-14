module Test.Main where

import Data.Maybe
import Data.Tuple(Tuple(..))
import Prelude
import Signal
import Signal.Time
import Signal.Channel
import Test.Signal
import Test.Unit

main = runTest do

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

  test "sampleOn samples values from sig2 when sig1 changes" do
    expect 150 (sampleOn (every 40.0) $ tick 10 20 [1, 2, 3, 4, 5, 6]) [1, 3, 5, 6]

  test "dropRepeats only yields when value is /= previous" do
    expect 50 (dropRepeats $ tick 1 1 [1, 1, 2, 2, 1, 3, 3]) [1, 2, 1, 3]

  test "zip with Tuple yields a tuple of both signals" do
    expect 50 (zip Tuple (tick 2 4 [1, 2, 3]) (tick 4 4 [1, 2, 3]))
      [Tuple 1 1, Tuple 2 1, Tuple 2 2, Tuple 3 2, Tuple 3 3]

  test "sum up values with foldp" do
    expect 50 (foldp (+) 0 $ tick 1 1 [1, 2, 3, 4, 5]) [1, 3, 6, 10, 15]

  test "filter values with filter" do
    expect 50 (filter (\n -> n < 5) 0 $ tick 1 1 [5, 3, 8, 4]) [0, 3, 4]

  test "filter Maybe values with filterMap" do
    expect 50 (filterMap (\n -> if n < 5 then Just n else Nothing)
                 0 $ tick 1 1 [5, 3, 8, 4]) [0, 3, 4]

  test "channel subscriptions yield when we send to the channel" do
    timeout 50 $ testFn \done -> do
      chan <- channel 1
      runSignal $ tick 1 1 [2, 3, 4] ~> send chan
      expectFn (subscribe chan) [2, 3, 4] done

  test "delayed signal yields same values" do
    expect 50 (delay 40.0 $ tick 1 1 [1, 2, 3, 4, 5]) [1, 2, 3, 4, 5]

  test "since yields true only once for multiple yields, then false" do
    expect 25 (since 10.0 $ tick 1 1 [1, 2, 3]) [false, true, false]
