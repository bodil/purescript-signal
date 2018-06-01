# purescript-signal

[![Build Status](https://travis-ci.org/bodil/purescript-signal.svg?branch=master)](https://travis-ci.org/bodil/purescript-signal)

Signal is a lightweight FRP-like library heavily inspired by the Elm Signal implementation. Where possible and sensible, it tries to maintain API equivalence with Elm.

See [the Elm documentation](http://elm-lang.org:1234/guide/reactivity#signals) for details on usage and principles.

## PureScript Usage Patterns

PureScript depends on effects (specifically, the `Effect` monad) to manage side effects, where Elm's runtime generally manages them for you. `purescript-signal` provides the `Signal.runSignal` function for running effectful signals.

```purescript
module Main where

import Effect.Console
import Effect (Effect)
import Prelude
import Signal

hello :: Signal String
hello = constant "Hello Joe!"

helloEffect :: Signal (Effect Unit)
helloEffect = hello ~> log

main = runSignal helloEffect
```

This simple example takes a constant signal which contains the string `"Hello Joe!"` and maps it over the `Effect.Console.log` function, which has the type `String -> Effect Unit`, thus taking the `String` content of the signal and turning it into an effect which logs the provided string to the user's console.

This gives us a `Signal (Effect Unit)`. We use `runSignal` to take the signal of effects and run each effect in turn—in our case, just the one effect which prints `"Hello Joe!"` to the console.

## API Documentation

* [Module documentation on Pursuit](https://pursuit.purescript.org/packages/purescript-signal/)

## Usage Examples

* The canonical Elm Mario: https://github.com/michaelficarra/purescript-demo-mario
* Ponies: https://github.com/bodil/purescript-is-magic
