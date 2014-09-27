# purescript-signal

Early draft. Seems to work.

See also [the Elm Signal documentation](http://library.elm-lang.org/catalog/elm-lang-Elm/0.12.3/Signal).

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

    applySig :: forall a b. Signal (a -> b) -> Signal a -> Signal b

    constant :: forall a. a -> Signal a

    foldp :: forall a b. (a -> b -> b) -> b -> Signal a -> Signal b

    lift :: forall a b. (a -> b) -> Signal a -> Signal b

    merge :: forall a. Signal a -> Signal a -> Signal a

    runSignal :: forall e. Signal (Eff e Unit) -> Eff e Unit

    sampleOn :: forall a b. Signal a -> Signal b -> Signal b

    unwrap :: forall e a. Signal (Eff e a) -> Eff e (Signal a)


## Module Signal.DOM

### Values

    animationFrame :: forall e. Eff (dom :: DOM | e) (Signal Time)

    keyPressed :: forall e. Number -> Eff (dom :: DOM | e) (Signal Boolean)

    mousePos :: forall e. Eff (dom :: DOM | e) (Signal { y :: Number, x :: Number })


## Module Signal.Time

### Types

    type Time  = Number


### Values

    every :: Time -> Signal Time

    millisecond :: Time

    now :: forall e. Eff (dom :: DOM | e) Time

    second :: Time
