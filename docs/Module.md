# Module Documentation

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


    distinct :: forall a. (Eq a) => Signal a -> Signal a


    distinct' :: forall a. Signal a -> Signal a


    foldp :: forall a b. (a -> b -> b) -> b -> Signal a -> Signal b


    keepIf :: forall a. (a -> Boolean) -> a -> Signal a -> Signal a


    map :: forall a b. (a -> b) -> Signal a -> Signal b


    merge :: forall a. Signal a -> Signal a -> Signal a


    runSignal :: forall e. Signal (Eff e Unit) -> Eff e Unit


    sampleOn :: forall a b. Signal a -> Signal b -> Signal b


    unwrap :: forall a e. Signal (Eff e a) -> Eff e (Signal a)


    zip :: forall a b c. (a -> b -> c) -> Signal a -> Signal b -> Signal c


## Module Signal.Channel

### Types


    data Chan :: !


    data Channel :: * -> *


### Values


    channel :: forall a e. a -> Eff (chan :: Chan | e) (Channel a)


    send :: forall a e. Channel a -> a -> Eff (chan :: Chan | e) Unit


    subscribe :: forall a. Channel a -> Signal a


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

     |Returns the number of milliseconds since an arbitrary, but constant, time in the past.

    now :: forall e. Eff (timer :: Timer | e) Time


    second :: Time



