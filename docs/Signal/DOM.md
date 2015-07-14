## Module Signal.DOM

#### `CoordinatePair`

``` purescript
type CoordinatePair = { x :: Int, y :: Int }
```

#### `keyPressed`

``` purescript
keyPressed :: forall e. Int -> Eff (dom :: DOM | e) (Signal Boolean)
```

#### `mouseButton`

``` purescript
mouseButton :: forall e. Int -> Eff (dom :: DOM | e) (Signal Boolean)
```

#### `Touch`

``` purescript
type Touch = { id :: String, screenX :: Int, screenY :: Int, clientX :: Int, clientY :: Int, pageX :: Int, pageY :: Int, radiusX :: Int, radiusY :: Int, rotationAngle :: Number, force :: Number }
```

#### `touch`

``` purescript
touch :: forall e. Eff (dom :: DOM | e) (Signal (Array Touch))
```

#### `tap`

``` purescript
tap :: forall e. Eff (dom :: DOM | e) (Signal Boolean)
```

#### `mousePos`

``` purescript
mousePos :: forall e. Eff (dom :: DOM | e) (Signal CoordinatePair)
```

#### `animationFrame`

``` purescript
animationFrame :: forall e. Eff (dom :: DOM, timer :: Timer | e) (Signal Time)
```


