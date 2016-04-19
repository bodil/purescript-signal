// module Signal.DOM

exports.keyPressedP =
  function keyPressedP(constant) {
    return function(keyCode) {
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
    };
  };

exports.mouseButtonP =
  function mouseButtonP(constant) {
    return function(button) {
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
    };
  };

exports.touchP =
  function touchP(constant) {
    var out = constant([]);
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
  };

exports.mousePosP =
  function mousePosP(constant) {
    var out = constant({x:0,y:0});
    window.addEventListener('mousemove', function(e) {
      if (e.pageX !== undefined && e.pageY !== undefined) {
        out.set({x: e.pageX, y: e.pageY});
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
  };

exports.animationFrameP =
  function animationFrameP(constant) {
    return function(now) {
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
    };
  };

exports.windowDimensionsP = function windowDimensionsP(constant) {
  var out = constant({ w: window.innerWidth, h: window.innerHeight });
  window.addEventListener("resize", function() {
    out.set({ w: window.innerWidth, h: window.innerHeight });
  });
  return function() {
    return out;
  }
}
