module Control.RAF.Spec where

import Control.RAF
import Control.Timer
import Control.Monad.ST
import Control.Monad.Eff
import Test.Mocha
import Test.Chai
import Debug.Trace

spec = describe "Request Animation Frame" do

  itAsync "should fire" $ requestAnimationFrame <<< itIs 

  itAsync "should fire as many times as called" \done -> 
    let requestAndInc = requestAnimationFrame <<< flip modifySTRef \x -> x + 1
    in do count <- newSTRef 0
          requestAndInc count
          requestAndInc count
          requestAndInc count
          timeout 33 do count' <- readSTRef count
                        expect count' `toEqual` 3
                        itIs done