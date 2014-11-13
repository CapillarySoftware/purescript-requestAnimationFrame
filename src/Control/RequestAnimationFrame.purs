module Control.RAF where

import Control.Monad.Eff

-- http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/

foreign import data RAF :: !

foreign import requestAnimationFrame """
  
  var rAF = (function(){
    return  window.requestAnimationFrame       ||
            window.webkitRequestAnimationFrame ||
            window.mozRequestAnimationFrame    ||
            function( callback ){
              window.setTimeout(callback, 1000 / 60);
            };
  })();

  function requestAnimationFrame(x){
    return function(){ 
      return rAF(x); 
    };
  };
  
""" :: forall a e. Eff (raf :: RAF | e) a -> Eff (raf :: RAF | e) Unit