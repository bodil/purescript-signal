## Module Signal

#### `Signal`

``` purescript
data Signal :: * -> *
```

##### Instances
``` purescript
instance functorSignal :: Functor Signal
instance applySignal :: Apply Signal
instance applicativeSignal :: Applicative Signal
instance semigroupSignal :: Semigroup (Signal a)
```

#### `constant`

``` purescript
constant :: forall a. a -> Signal a
```

Creates a signal with a constant value.

#### `merge`

``` purescript
merge :: forall a. Signal a -> Signal a -> Signal a
```

Merge two signals, returning a new signal which will yield a value
whenever either of the input signals yield. Its initial value will be
that of the first signal.

#### `mergeMany`

``` purescript
mergeMany :: forall f a. (Functor f, Foldable f) => f (Signal a) -> Maybe (Signal a)
```

Merge all signals inside a `Foldable`, returning a `Maybe` which will
either contain the resulting signal, or `Nothing` if the `Foldable`
was empty.

#### `foldp`

``` purescript
foldp :: forall a b. (a -> b -> b) -> b -> Signal a -> Signal b
```

Creates a past dependent signal. The function argument takes the value of
the input signal, and the previous value of the output signal, to produce
the new value of the output signal.

#### `sampleOn`

``` purescript
sampleOn :: forall a b. Signal a -> Signal b -> Signal b
```

Creates a signal which yields the current value of the second signal every
time the first signal yields.

#### `dropRepeats`

``` purescript
dropRepeats :: forall a. (Eq a) => Signal a -> Signal a
```

Create a signal which only yields values which aren't equal to the previous
value of the input signal.

#### `dropRepeats'`

``` purescript
dropRepeats' :: forall a. Signal a -> Signal a
```

Create a signal which only yields values which aren't equal to the previous
value of the input signal, using JavaScript's `!==` operator to determine
disequality.

#### `runSignal`

``` purescript
runSignal :: forall e. Signal (Eff e Unit) -> Eff e Unit
```

Given a signal of effects with no return value, run each effect as it
comes in.

#### `unwrap`

``` purescript
unwrap :: forall a e. Signal (Eff e a) -> Eff e (Signal a)
```

Takes a signal of effects of `a`, and produces an effect which returns a
signal which will take each effect produced by the input signal, run it,
and yield its returned value.

#### `filter`

``` purescript
filter :: forall a. (a -> Boolean) -> a -> Signal a -> Signal a
```

Takes a signal and filters out yielded values for which the provided
predicate function returns `false`.

#### `filterMap`

``` purescript
filterMap :: forall a b. (a -> Maybe b) -> b -> Signal a -> Signal b
```

Map a signal over a function which returns a `Maybe`, yielding only the
values inside `Just`s, dropping the `Nothing`s.

#### `(<~)`

``` purescript
(<~) :: forall f a b. (Functor f) => (a -> b) -> f a -> f b
```

_left-associative / precedence 4_

#### `(~>)`

``` purescript
(~>) :: forall f a b. (Functor f) => f a -> (a -> b) -> f b
```

_left-associative / precedence 4_

#### `(~)`

``` purescript
(~) :: forall f a b. (Apply f) => f (a -> b) -> f a -> f b
```

_left-associative / precedence 4_


