module Signal.DOM
  ( animationFrame
  , keyPressed
  , mouseButton
  , mouseButtonPressed
  , touch
  , tap
  , mousePos
  , windowDimensions
  , CoordinatePair(..)
  , DimensionPair(..)
  , Touch(..)
  , MouseButton (..)
  ) where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Timer (TIMER)
import DOM (DOM)
import Prelude (($), bind, pure)
import Signal (constant, Signal, (~>))
import Signal.Time (now, Time)

type CoordinatePair = { x :: Int, y :: Int }
type DimensionPair  = { w :: Int, h :: Int }
data MouseButton = MouseLeftButton | MouseMiddleButton | MouseIE8MiddleButton | MouseRightButton

foreign import keyPressedP :: forall e c. (c -> Signal c) -> Int -> Eff (dom :: DOM | e) (Signal Boolean)

-- |Creates a signal which will be `true` when the key matching the given key
-- |code is pressed, and `false` when it's released.
keyPressed :: forall e. Int -> Eff (dom :: DOM | e) (Signal Boolean)
keyPressed = keyPressedP constant

foreign import mouseButtonP :: forall e c. (c -> Signal c) -> Int -> Eff (dom :: DOM | e) (Signal Boolean)


-- |Creates a signal which will be `true` when the given mouse button is
-- |pressed, and `false` when it's released.
mouseButton :: forall e. Int -> Eff (dom :: DOM | e) (Signal Boolean)
mouseButton = mouseButtonP constant


-- |Creates a signal which will be `true` when the given mouse button is
-- |pressed, and `false` when it's released.
-- |note: in IE8 and earlier you need to use MouseIE8MiddleButton if you want to query the middle button
mouseButtonPressed :: forall e. MouseButton -> Eff (dom :: DOM | e) (Signal Boolean)
mouseButtonPressed btn = mouseButton buttonNumber
  where 
    buttonNumber = case btn of
      MouseLeftButton      -> 0
      MouseRightButton     -> 2
      MouseMiddleButton    -> 1
      MouseIE8MiddleButton -> 4

type Touch = { id :: String
             , screenX :: Int, screenY :: Int
             , clientX :: Int, clientY :: Int
             , pageX :: Int, pageY :: Int
             , radiusX :: Int, radiusY :: Int
             , rotationAngle :: Number, force :: Number }

foreign import touchP :: forall e c. (c -> Signal c) -> Eff (dom :: DOM | e) (Signal (Array Touch))

-- |A signal containing the current state of the touch device, as described by
-- |the `Touch` record type.
touch :: forall e. Eff (dom :: DOM | e) (Signal (Array Touch))
touch = touchP constant

-- |A signal which will be `true` when at least one finger is touching the
-- |touch device, and `false` otherwise.
tap :: forall e. Eff (dom :: DOM | e) (Signal Boolean)
tap = do
  touches <- touch
  pure $ touches ~> \t -> case t of
    [] -> false
    _ -> true

foreign import mousePosP :: forall e c. (c -> Signal c) -> Eff (dom :: DOM | e) (Signal CoordinatePair)

-- |A signal containing the current mouse position.
mousePos :: forall e. Eff (dom :: DOM | e) (Signal CoordinatePair)
mousePos = mousePosP constant

foreign import animationFrameP :: forall e c. (c -> Signal c) -> Eff (timer :: TIMER | e) Time -> Eff (dom :: DOM, timer :: TIMER | e) (Signal Time)

-- |A signal which yields the current time, as determined by `now`, on every
-- |animation frame (see [https://developer.mozilla.org/en-US/docs/Web/API/window/requestAnimationFrame]).
animationFrame :: forall e. Eff (dom :: DOM, timer :: TIMER | e) (Signal Time)
animationFrame = animationFrameP constant now

foreign import windowDimensionsP :: forall e c. (c -> Signal c) -> Eff (dom :: DOM | e) (Signal DimensionPair)

-- |A signal which contains the document window's current width and height.
windowDimensions :: forall e. Eff (dom :: DOM | e) (Signal DimensionPair)
windowDimensions = windowDimensionsP constant
