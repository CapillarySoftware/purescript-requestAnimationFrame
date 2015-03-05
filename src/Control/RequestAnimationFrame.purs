module Control.RAF where

import Control.Monad.Eff

-- http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/

foreign import data RAF :: !

foreign import requestAnimationFrame """

  var requestAnimationFrame = (function(){
    var rAF = typeof requestAnimationFrame === "function" ? requestAnimationFrame :
              typeof webkitRequestAnimationFrame === "function" ? webkitRequestAnimationFrame :
              typeof mozRequestAnimationFrame === "function" ? mozRequestAnimationFrame :
              function(callback) { return setTimeout(callback, 1000 / 60); };

    return function(x) { return function(){ return rAF(x); }; };
  }());
  
""" :: forall a e. Eff (raf :: RAF | e) a -> Eff (raf :: RAF | e) Unit