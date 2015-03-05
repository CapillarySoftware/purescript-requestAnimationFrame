module Control.RAF where

import Control.Monad.Eff
import Context

-- http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/

foreign import data RAF :: !

foreign import requestAnimationFrame_ """
  var rAF = null;

  function requestAnimationFrame_(context){
    return function(x){

      if(!rAF){
        rAF = (function(){
          var c = context();
          return  c.requestAnimationFrame       ||
                  c.webkitRequestAnimationFrame ||
                  c.mozRequestAnimationFrame    ||
                  function( callback ){
                    c.setTimeout(callback, 1000 / 60);
                  };
        })();
      }

      return function(){
        return rAF(x);
      };

    }
  };

""" :: forall a e. Eff e Context -> Eff (raf :: RAF | e) a -> Eff (raf :: RAF | e) Unit

requestAnimationFrame :: forall a e. Eff (raf :: RAF | e) a -> Eff (raf :: RAF | e) Unit
requestAnimationFrame =  requestAnimationFrame_ getContext