## Module Signal.DOM

#### `CoordinatePair`

``` purescript
type CoordinatePair = { x :: Int, y :: Int }
```

#### `DimensionPair`

``` purescript
type DimensionPair = { w :: Int, h :: Int }
```

#### `keyPressed`

``` purescript
keyPressed :: forall e. Int -> Eff (dom :: DOM | e) (Signal Boolean)
```

Creates a signal which will be `true` when the key matching the given key
code is pressed, and `false` when it's released.

#### `mouseButton`

``` purescript
mouseButton :: forall e. Int -> Eff (dom :: DOM | e) (Signal Boolean)
```

Creates a signal which will be `true` when the given mouse button is
pressed, and `false` when it's released.

#### `Touch`

``` purescript
type Touch = { id :: String, screenX :: Int, screenY :: Int, clientX :: Int, clientY :: Int, pageX :: Int, pageY :: Int, radiusX :: Int, radiusY :: Int, rotationAngle :: Number, force :: Number }
```

#### `touch`

``` purescript
touch :: forall e. Eff (dom :: DOM | e) (Signal (Array Touch))
```

A signal containing the current state of the touch device, as described by
the `Touch` record type.

#### `tap`

``` purescript
tap :: forall e. Eff (dom :: DOM | e) (Signal Boolean)
```

A signal which will be `true` when at least one finger is touching the
touch device, and `false` otherwise.

#### `mousePos`

``` purescript
mousePos :: forall e. Eff (dom :: DOM | e) (Signal CoordinatePair)
```

A signal containing the current mouse position.

#### `animationFrame`

``` purescript
animationFrame :: forall e. Eff (dom :: DOM, timer :: Timer | e) (Signal Time)
```

A signal which yields the current time, as determined by `now`, on every
animation frame (see [https://developer.mozilla.org/en-US/docs/Web/API/window/requestAnimationFrame]).

#### `windowDimensions`

``` purescript
windowDimensions :: forall e. Eff (dom :: DOM | e) (Signal DimensionPair)
```

A signal which contains the document window's current width and height.


