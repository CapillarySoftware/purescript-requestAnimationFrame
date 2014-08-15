module Control.Reactive.RAF.Spec where

import Control.Reactive.RAF
import Control.Monad.ST
import Control.Monad.Eff
import Test.Mocha
import Test.Chai
import Debug.Trace

spec = describe "Request Animation Frame" $ do

  itAsync "should fire" $ \done -> 
    requestAnimationFrame $ itIs done


