module Signal.DOM
  ( animationFrame
  , keyPressed
  , mouseButton
  , touch
  , tap
  , mousePos
  , windowDims
  , CoordinatePair(..)
  , DimensionPair(..)
  , Touch(..)
  ) where

import Control.Monad.Eff (Eff(..))
import Control.Timer (Timer(..))
import Data.Function
import DOM (DOM(..))
import Signal (constant, Signal(..), (~>), unwrap)
import Signal.Time (now, Time(..))

type CoordinatePair = { x :: Number, y :: Number }
type DimensionPair  = { w :: Number, h :: Number }

foreign import keyPressedP """
  function keyPressedP(constant, keyCode) {
    return function() {
      var out = constant(false);
      window.addEventListener("keydown", function(e) {
        if (e.keyCode === keyCode) out.set(true);
      });
      window.addEventListener("keyup", function(e) {
        if (e.keyCode === keyCode) out.set(false);
      });
      return out;
    };
  }""" :: forall e c. Fn2 (c -> Signal c) Number (Eff (dom :: DOM | e) (Signal Boolean))

keyPressed :: forall e. Number -> Eff (dom :: DOM | e) (Signal Boolean)
keyPressed = runFn2 keyPressedP constant

foreign import mouseButtonP """
  function mouseButtonP(constant, button) {
    return function() {
      var out = constant(false);
      window.addEventListener("mousedown", function(e) {
        if (e.button === button) out.set(true);
      });
      window.addEventListener("mouseup", function(e) {
        if (e.button === button) out.set(false);
      });
      return out;
    };
  }""" :: forall e c. Fn2 (c -> Signal c) Number (Eff (dom :: DOM | e) (Signal Boolean))

mouseButton :: forall e. Number -> Eff (dom :: DOM | e) (Signal Boolean)
mouseButton = runFn2 mouseButtonP constant

type Touch = { id :: String
             , screenX :: Number, screenY :: Number
             , clientX :: Number, clientY :: Number
             , pageX :: Number, pageY :: Number
             , radiusX :: Number, radiusY :: Number
             , rotationAngle :: Number, force :: Number }

foreign import touchP """
  function touchP(constant) {
    var out = constant(false);
    function report(e) {
      var touches = [], i, l = e.touches.length;
      for (i = 0; i < l; i++) touches.push(e.touches.item(i));
      out.set(touches);
    }
    window.addEventListener("touchstart", report);
    window.addEventListener("touchend", report);
    window.addEventListener("touchmove", report);
    window.addEventListener("touchcancel", report);
    return function() {
      return out;
    };
  }""" :: forall e c. Fn1 (c -> Signal c) (Eff (dom :: DOM | e) (Signal [Touch]))

touch :: forall e. Eff (dom :: DOM | e) (Signal [Touch])
touch = runFn1 touchP constant

tap :: forall e. Eff (dom :: DOM | e) (Signal Boolean)
tap = do
  touches <- touch
  return $ touches ~> \t -> case t of
    [] -> false
    _ -> true

foreign import mousePosP """
  function mousePosP(constant) {
    var out = constant({x:0,y:0});
    window.addEventListener('mousemove', function(e) {
      if (e.pageX !== undefined && e.pageY !== undefined) {
        out.set({x:e.pageX, y: e.pageY});
      } else if (e.clientX !== undefined && e.clientY !== undefined) {
        out.set({
          x: e.clientX + document.body.scrollLeft +
             document.documentElement.scrollLeft,
          y: e.clientY + document.body.scrollTop +
             document.documentElement.scrollTop
        });
      } else {
        throw new Error('Mouse event has no coordinates I recognise!');
      }
    });
    return function() {
      return out;
    };
  }""" :: forall e c. (c -> Signal c) -> Eff (dom :: DOM | e) (Signal CoordinatePair)

mousePos :: forall e. Eff (dom :: DOM | e) (Signal CoordinatePair)
mousePos = mousePosP constant

foreign import windowDimsP """
  function windowDimsP(constant) {
    var out = constant({ w: window.innerWidth, h: innerHeight });
    window.addEventListener("resize", function() {
       out.set({ w: window.innerWidth, h: window.innerHeight });
    });
    return function() {
      return out;
    }
  }""" :: forall e c. (c -> Signal c) -> Eff (dom :: DOM | e) (Signal DimensionPair)

windowDims :: forall e. Eff (dom :: DOM | e) (Signal DimensionPair)
windowDims = windowDimsP constant

foreign import animationFrameP """
  function animationFrameP(constant, now) {
    return function() {
      var requestAnimFrame, cancelAnimFrame;
      if (window.requestAnimationFrame) {
        requestAnimFrame = window.requestAnimationFrame;
        cancelAnimFrame = window.cancelAnimationFrame;
      } else if (window.mozRequestAnimationFrame) {
        requestAnimFrame = window.mozRequestAnimationFrame;
        cancelAnimFrame = window.mozCancelAnimationFrame;
      } else if (window.webkitRequestAnimationFrame) {
        requestAnimFrame = window.webkitRequestAnimationFrame;
        cancelAnimFrame = window.webkitCancelAnimationFrame;
      } else if (window.msRequestAnimationFrame) {
        requestAnimFrame = window.msRequestAnimationFrame;
        cancelAnimFrame = window.msCancelAnimationFrame;
      } else if (window.oRequestAnimationFrame) {
        requestAnimFrame = window.oRequestAnimationFrame;
        cancelAnimFrame = window.oCancelAnimationFrame;
      } else {
        requestAnimFrame = function(cb) {setTimeout(function() {cb(now())}, 1000/60)};
        cancelAnimFrame = window.clearTimeout;
      }
      var out = constant(now());
      requestAnimFrame(function tick(t) {
        out.set(t); requestAnimFrame(tick);
      });
      return out;
    };
  }""" :: forall e c. Fn2 (c -> Signal c) (Eff (timer :: Timer | e) Time) (Eff (dom :: DOM, timer :: Timer | e) (Signal Time))

animationFrame :: forall e. Eff (dom :: DOM, timer :: Timer | e) (Signal Time)
animationFrame = runFn2 animationFrameP constant now
