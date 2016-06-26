"use strict";

// module DOM.RequestAnimationFrame

// The polyfill is a first-class effectful export. We have to store the result
// of the polyfill somewhere, so why not on the provided window? And, then,
// it is just an effect (in Purescript terms), so we can model it that way.
//
// For testing purposes, I've made it so that this actually can run under
// Node -- you just have to unsafely coerce something to be a `Window`.
// Of course, there's no point in doing that in practice, since there's
// no particular resaon to be tied to 60 FPS on Node. (That is, you'd want
// a completely different API to set your own frame rate on Node).
//
// The polyfill is based on the following gist:
//
//     https://gist.github.com/jonasfj/4438815
//
// which, in turn, gives the following credits:
//
//     http://paulirish.com/2011/requestanimationframe-for-smart-animating/
//     http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating
//
//     requestAnimationFrame polyfill by Erik Möller
//     fixes from Paul Irish and Tino Zijdel
//     list-based fallback implementation by Jonas Finnemann Jensen
exports.applyPolyfillIfNeeded = function (window_) {
    return function () {
        // We check for both, since we need both and they need to be consistent
        if (!window_.requestAnimationFrame || !window_.cancelAnimationFrame) {
            var vendors = ['webkit', 'moz'];

            for (var x = 0; x < vendors.length && !window_.requestAnimationFrame; ++x) {
                window_.requestAnimationFrame = window_[vendors[x] + 'RequestAnimationFrame'];

                window_.cancelAnimationFrame =
                    window_[vendors[x] + 'CancelAnimationFrame'] ||
                    window_[vendors[x] + 'CancelRequestAnimationFrame'];
            }

            // Again, we double-check for both
            if (!window_.requestAnimationFrame || !window_.cancelAnimationFrame) {
                // If still not present, apply the polyfill.
                var tid = null, cbs = [], nb = 0, ts = Date.now();

                var animate = function animate () {
                    var i, clist = cbs, len = cbs.length;
                    tid = null;
                    ts = Date.now();
                    cbs = [];
                    nb += clist.length;

                    for (i = 0; i < len; i++) {
                        if (clist[i]) clist[i](ts);
                    }
                };

                window_.requestAnimationFrame = function (cb) {
                    if (tid === null) {
                        tid = setTimeout(animate, Math.max(0, 20 + ts - Date.now()));
                    }

                    return cbs.push(cb) + nb;
                };

                window_.cancelAnimationFrame = function (id) {
                    delete cbs[id - nb - 1];
                };
            }
        }
    };
};

// The rest assume that the polyfill has already been applied, if needed
exports.requestAnimationFrameImpl = function (window_) {
    return function (callback) {
        return function () {
            return window_.requestAnimationFrame(function (time) {
                // The callback is a function from the time to an effect. So
                // we call the callback to get the effect, and then we immediately
                // execute it (since now is the time we promised to do that).
                callback(time)();
            });
        };
    };
};

exports.cancelAnimationFrameImpl = function (window_) {
    return function (requestID) {
        return function () {
            window_.cancelAnimationFrame(requestID);
        };
    };
};
