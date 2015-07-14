## Module Signal.Time

#### `Time`

``` purescript
type Time = Number
```

#### `millisecond`

``` purescript
millisecond :: Time
```

#### `second`

``` purescript
second :: Time
```

#### `every`

``` purescript
every :: Time -> Signal Time
```

#### `now`

``` purescript
now :: forall e. Eff (timer :: Timer | e) Time
```

Returns the number of milliseconds since an arbitrary, but constant, time in the past.

#### `delay`

``` purescript
delay :: forall a. Time -> Signal a -> Signal a
```

Takes a signal and delays its yielded values by a given number of
milliseconds.


