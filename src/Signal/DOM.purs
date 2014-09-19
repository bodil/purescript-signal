module Signal.DOM (
  keyPressed,
  mousePos,
  animationFrame
  ) where

import Control.Monad.Eff
import Signal
import Signal.Time
import DOM

_constant = constant
_now = now

foreign import keyPressed
  "function keyPressed(keyCode) {\
  \  return function() {\
  \    var out = _constant(false);\
  \    window.addEventListener('keydown', function(e) {\
  \      if (e.keyCode === keyCode) out.set(true);\
  \    });\
  \    window.addEventListener('keyup', function(e) {\
  \      if (e.keyCode === keyCode) out.set(false);\
  \    });\
  \    return out;\
  \  };\
  \}" :: forall e. Number -> Eff (dom :: DOM | e) (Signal Boolean)

foreign import mousePos
  "function mousePos() {\
  \  var out = _constant({x:0,y:0});\
  \  window.addEventListener('mousemove', function(e) {\
  \    if (e.pageX !== undefined && e.pageY !== undefined) {\
  \      out.set({x:e.pageX, y: e.pageY});\
  \    } else if (e.clientX !== undefined && e.clientY !== undefined) {\
  \      out.set({\
  \        x: e.clientX + document.body.scrollLeft + \
  \           document.documentElement.scrollLeft,\
  \        y: e.clientY + document.body.scrollTop + \
  \           document.documentElement.scrollTop\
  \      });\
  \    } else {\
  \      throw new Error('Mouse event has no coordinates I recognise!');\
  \    }\
  \  });\
  \  return out;\
  \}" :: forall e. Eff (dom :: DOM | e) (Signal { x :: Number, y :: Number })

foreign import animationFrame
  "function animationFrame() {\
  \  var requestAnimFrame, cancelAnimFrame;\
  \  if (window.requestAnimationFrame) {\
  \    requestAnimFrame = window.requestAnimationFrame;\
  \    cancelAnimFrame = window.cancelAnimationFrame;\
  \  } else if (window.mozRequestAnimationFrame) {\
  \    requestAnimFrame = window.mozRequestAnimationFrame;\
  \    cancelAnimFrame = window.mozCancelAnimationFrame;\
  \  } else if (window.webkitRequestAnimationFrame) {\
  \    requestAnimFrame = window.webkitRequestAnimationFrame;\
  \    cancelAnimFrame = window.webkitCancelAnimationFrame;\
  \  } else if (window.msRequestAnimationFrame) {\
  \    requestAnimFrame = window.msRequestAnimationFrame;\
  \    cancelAnimFrame = window.msCancelAnimationFrame;\
  \  } else if (window.oRequestAnimationFrame) {\
  \    requestAnimFrame = window.oRequestAnimationFrame;\
  \    cancelAnimFrame = window.oCancelAnimationFrame;\
  \  } else {\
  \    requestAnimFrame = function(cb) {setTimeout(function() {cb(_now())}, 1000/60)};\
  \    cancelAnimFrame = window.clearTimeout;\
  \  }\
  \  var out = _constant(Date.now());\
  \  requestAnimFrame(function tick(t) {\
  \    out.set(t); requestAnimFrame(tick);\
  \  });\
  \  return out;\
  \}" :: forall e. Eff (dom :: DOM | e) (Signal Time)
