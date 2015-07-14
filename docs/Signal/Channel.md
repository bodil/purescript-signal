## Module Signal.Channel

#### `Channel`

``` purescript
data Channel :: * -> *
```

#### `Chan`

``` purescript
data Chan :: !
```

#### `channel`

``` purescript
channel :: forall a e. a -> Eff (chan :: Chan | e) (Channel a)
```

Creates a channel, which allows you to feed arbitrary values into a signal.

#### `send`

``` purescript
send :: forall a e. Channel a -> a -> Eff (chan :: Chan | e) Unit
```

Sends a value to a given channel.

#### `subscribe`

``` purescript
subscribe :: forall a. Channel a -> Signal a
```

Takes a channel and returns a signal of the values sent to it.


