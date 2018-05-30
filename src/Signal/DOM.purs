module Signal.DOM
  ( animationFrame
  , keyPressed
  , mouseButton
  , touch
  , tap
  , mousePos
  , windowDimensions
  , CoordinatePair(..)
  , DimensionPair(..)
  , Touch(..)
  ) where


import Effect (Effect)
import Prelude (($), bind, pure)
import Signal (constant, Signal, (~>))
import Signal.Time (now, Time)

type CoordinatePair = { x :: Int, y :: Int }
type DimensionPair  = { w :: Int, h :: Int }

foreign import keyPressedP :: forall c. (c -> Signal c) -> Int -> Effect (Signal Boolean)

-- |Creates a signal which will be `true` when the key matching the given key
-- |code is pressed, and `false` when it's released.
keyPressed :: Int -> Effect (Signal Boolean)
keyPressed = keyPressedP constant

foreign import mouseButtonP :: forall c. (c -> Signal c) -> Int -> Effect (Signal Boolean)

-- |Creates a signal which will be `true` when the given mouse button is
-- |pressed, and `false` when it's released.
mouseButton :: Int -> Effect(Signal Boolean)
mouseButton = mouseButtonP constant

type Touch = { id :: String
             , screenX :: Int, screenY :: Int
             , clientX :: Int, clientY :: Int
             , pageX :: Int, pageY :: Int
             , radiusX :: Int, radiusY :: Int
             , rotationAngle :: Number, force :: Number }

foreign import touchP :: forall c. (c -> Signal c) -> Effect (Signal (Array Touch))

-- |A signal containing the current state of the touch device, as described by
-- |the `Touch` record type.
touch :: Effect (Signal (Array Touch))
touch = touchP constant

-- |A signal which will be `true` when at least one finger is touching the
-- |touch device, and `false` otherwise.
tap :: Effect (Signal Boolean)
tap = do
  touches <- touch
  pure $ touches ~> \t -> case t of
    [] -> false
    _ -> true

foreign import mousePosP :: forall c. (c -> Signal c) -> Effect (Signal CoordinatePair)

-- |A signal containing the current mouse position.
mousePos :: Effect (Signal CoordinatePair)
mousePos = mousePosP constant

foreign import animationFrameP :: forall c. (c -> Signal c) -> Effect Time -> Effect (Signal Time)

-- |A signal which yields the current time, as determined by `now`, on every
-- |animation frame (see [https://developer.mozilla.org/en-US/docs/Web/API/window/requestAnimationFrame]).
animationFrame :: Effect (Signal Time)
animationFrame = animationFrameP constant now

foreign import windowDimensionsP :: forall c. (c -> Signal c) -> Effect (Signal DimensionPair)

-- |A signal which contains the document window's current width and height.
windowDimensions :: Effect (Signal DimensionPair)
windowDimensions = windowDimensionsP constant
