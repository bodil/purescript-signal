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

#### `since`

``` purescript
since :: forall a. Time -> Signal a -> Signal Boolean
```

Takes a signal and a time value, and creates a signal which yields `True`
when the input signal yields, then goes back to `False` after the given
number of milliseconds have elapsed, unless the input signal yields again
in the interim.


