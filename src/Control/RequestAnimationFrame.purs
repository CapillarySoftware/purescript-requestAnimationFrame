module Control.RAF where

import Control.Monad.Eff

-- http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/

foreign import data RAF :: !

foreign import requestAnimationFrame """

  var rAF = (function(){
    var singleton;

    function init() {
      var shim = window.requestAnimationFrame       ||
                 window.webkitRequestAnimationFrame ||
                 window.mozRequestAnimationFrame    ||
                 function( callback ){
                   window.setTimeout(callback, 1000 / 60);
                 };

      return {
        requestAnimationFrame : shim
      };
    }

    return {
      getSingleton : function(){
        if(!singleton) {
          singleton = init();
        }
        return singleton;
      }
    }
  })();
  
  function requestAnimationFrame(x) {
    return function(){ 
      return rAF.getSingleton().requestAnimationFrame(x); 
    };
  };
  
""" :: forall a e. Eff (raf :: RAF | e) a -> Eff (raf :: RAF | e) Unit