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
          return  context.requestAnimationFrame       ||
                  context.webkitRequestAnimationFrame ||
                  context.mozRequestAnimationFrame    ||
                  function( callback ){
                    context.setTimeout(callback, 1000 / 60);
                  };
        })();
      }

      return function(){
        return rAF(x);
      };

    }
  };

""" :: forall a e. Context -> Eff (raf :: RAF | e) a -> Eff (raf :: RAF | e) Unit

requestAnimationFrame :: forall a e. Eff (raf :: RAF | e) a -> Eff (raf :: RAF | e) Unit
requestAnimationFrame = getContext >>= requestAnimationFrame_