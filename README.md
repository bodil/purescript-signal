# purescript-signal

Signal is a lightweight FRP library heavily inspired by the Elm Signal implementation. Where possible and sensible, it tries to maintain API equivalence with Elm.

See also [the Elm Signal documentation](http://library.elm-lang.org/catalog/elm-lang-Elm/0.12.3/Signal).

## Usage Examples

* The canonical Elm Mario: https://github.com/michaelficarra/purescript-demo-mario
* Ponies: https://github.com/bodil/purescript-is-magic

# API Documentation

## Module Signal

### Types

    data Signal :: * -> *


### Type Class Instances

    instance applicativeSignal :: Applicative Signal

    instance applySignal :: Apply Signal

    instance functorSignal :: Functor Signal

    instance semigroupSignal :: Semigroup (Signal a)


### Values

    (<~) :: forall f a b. (Functor f) => (a -> b) -> f a -> f b

    (~) :: forall f a b. (Apply f) => f (a -> b) -> f a -> f b

    (~>) :: forall f a b. (Functor f) => f a -> (a -> b) -> f b

    constant :: forall a. a -> Signal a

    distinct :: forall a. (Eq a) => Signal a -> Signal a

    distinct' :: forall a. Signal a -> Signal a

    runSignal :: forall e. Signal (Eff e Unit) -> Eff e Unit

    unwrap :: forall a e. Signal (Eff e a) -> Eff e (Signal a)

    zip :: forall a b c. (a -> b -> c) -> Signal a -> Signal b -> Signal c


## Module Signal.DOM

### Types

    type CoordinatePair = { y :: Number, x :: Number }

    type Touch = { force :: Number, rotationAngle :: Number, radiusY :: Number, radiusX :: Number, pageY :: Number, pageX :: Number, clientY :: Number, clientX :: Number, screenY :: Number, screenX :: Number, id :: String }


### Values

    animationFrame :: forall e. Eff (timer :: Timer, dom :: DOM | e) (Signal Time)

    keyPressed :: forall e. Number -> Eff (dom :: DOM | e) (Signal Boolean)

    mouseButton :: forall e. Number -> Eff (dom :: DOM | e) (Signal Boolean)

    mousePos :: forall e. Eff (dom :: DOM | e) (Signal CoordinatePair)

    tap :: forall e. Eff (dom :: DOM | e) (Signal Boolean)

    touch :: forall e. Eff (dom :: DOM | e) (Signal [Touch])


## Module Signal.Time

### Types

    type Time = Number


### Values

    every :: Time -> Signal Time

    millisecond :: Time

    now :: forall e. Eff (timer :: Timer | e) Time

    second :: Time
