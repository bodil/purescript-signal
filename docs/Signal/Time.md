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


