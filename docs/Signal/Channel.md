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

#### `send`

``` purescript
send :: forall a e. Channel a -> a -> Eff (chan :: Chan | e) Unit
```

#### `subscribe`

``` purescript
subscribe :: forall a. Channel a -> Signal a
```


