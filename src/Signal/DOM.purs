module Signal.DOM
  ( animationFrame
  , keyPressed
  , mouseButton
  , touch
  , tap
  , mousePos
  , CoordinatePair()
  , Touch()
  ) where

import Control.Monad.Eff (Eff(..))
import Control.Timer (Timer())
import DOM (DOM(..))
import Prelude (($), bind, return)
import Signal (constant, Signal(..), (~>), unwrap)
import Signal.Time (now, Time(..))

type CoordinatePair = { x :: Int, y :: Int }

foreign import keyPressedP :: forall e c. (c -> Signal c) -> Int -> Eff (dom :: DOM | e) (Signal Boolean)

keyPressed :: forall e. Int -> Eff (dom :: DOM | e) (Signal Boolean)
keyPressed = keyPressedP constant

foreign import mouseButtonP :: forall e c. (c -> Signal c) -> Int -> Eff (dom :: DOM | e) (Signal Boolean)

mouseButton :: forall e. Int -> Eff (dom :: DOM | e) (Signal Boolean)
mouseButton = mouseButtonP constant

type Touch = { id :: String
             , screenX :: Int, screenY :: Int
             , clientX :: Int, clientY :: Int
             , pageX :: Int, pageY :: Int
             , radiusX :: Int, radiusY :: Int
             , rotationAngle :: Number, force :: Number }

foreign import touchP :: forall e c. (c -> Signal c) -> Eff (dom :: DOM | e) (Signal (Array Touch))

touch :: forall e. Eff (dom :: DOM | e) (Signal (Array Touch))
touch = touchP constant

tap :: forall e. Eff (dom :: DOM | e) (Signal Boolean)
tap = do
  touches <- touch
  return $ touches ~> \t -> case t of
    [] -> false
    _ -> true

foreign import mousePosP :: forall e c. (c -> Signal c) -> Eff (dom :: DOM | e) (Signal CoordinatePair)

mousePos :: forall e. Eff (dom :: DOM | e) (Signal CoordinatePair)
mousePos = mousePosP constant

foreign import animationFrameP :: forall e c. (c -> Signal c) -> Eff (timer :: Timer | e) Time -> Eff (dom :: DOM, timer :: Timer | e) (Signal Time)

animationFrame :: forall e. Eff (dom :: DOM, timer :: Timer | e) (Signal Time)
animationFrame = animationFrameP constant now
