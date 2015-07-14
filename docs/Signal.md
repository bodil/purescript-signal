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

#### `mapSig`

``` purescript
mapSig :: forall a b. (a -> b) -> Signal a -> Signal b
```

#### `applySig`

``` purescript
applySig :: forall a b. Signal (a -> b) -> Signal a -> Signal b
```

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

#### `sampleOn`

``` purescript
sampleOn :: forall a b. Signal a -> Signal b -> Signal b
```

#### `distinct`

``` purescript
distinct :: forall a. (Eq a) => Signal a -> Signal a
```

#### `distinct'`

``` purescript
distinct' :: forall a. Signal a -> Signal a
```

#### `zip`

``` purescript
zip :: forall a b c. (a -> b -> c) -> Signal a -> Signal b -> Signal c
```

#### `runSignal`

``` purescript
runSignal :: forall e. Signal (Eff e Unit) -> Eff e Unit
```

#### `unwrap`

``` purescript
unwrap :: forall a e. Signal (Eff e a) -> Eff e (Signal a)
```

#### `filter`

``` purescript
filter :: forall a. (a -> Boolean) -> a -> Signal a -> Signal a
```

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


