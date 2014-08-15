module Control.Reactive.RAF where

import Control.Monad.Eff

-- http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/

foreign import data RAF :: !

foreign import requestAnimationFrame 
  "var requestAnimationFrame = (function(){\
  \  return  window.requestAnimationFrame       ||\
  \          window.webkitRequestAnimationFrame ||\
  \          window.mozRequestAnimationFrame    ||\
  \          function( callback ){\
  \            window.setTimeout(callback, 1000 / 60);\
  \          };\
  \})();" :: forall eff a. Eff eff a -> Eff (raf :: RAF | eff) Unit