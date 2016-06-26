-- | This module exposes a polyfilled `requestAnimationFrame` function.
module DOM.RequestAnimationFrame
    ( Request
    , requestAnimationFrame, requestAnimationFrame_
    , requestAnimationFrameWithTime, requestAnimationFrameWithTime_
    , cancelAnimationFrame
    ) where

import DOM (DOM)
import DOM.HTML (window)
import DOM.HTML.Types (Window)

import Data.Time.Duration (Milliseconds(..))
import Control.Monad.Eff (Eff)

import Prelude (Unit, bind, (>>=), pure, flip, ($), const, (<<<))


-- | A request for a callback via `requestAnimationFrame`. You can supply this to
-- | `cancelAnimationFrame` in order to cancel the request.
newtype Request = Request
    { win :: Window
    , id :: RequestID
    }

foreign import data RequestID :: *

foreign import applyPolyfillIfNeeded :: forall eff. Window -> Eff (dom :: DOM | eff) Unit

foreign import requestAnimationFrameImpl :: forall a eff. Window -> (Number -> Eff (dom :: DOM | eff) a) -> Eff (dom :: DOM | eff) RequestID

foreign import cancelAnimationFrameImpl :: forall eff. Window -> RequestID -> Eff (dom :: DOM | eff) Unit


-- | Request that the specified action be called on the next animation frame, specifying
-- | the `Window` object.
requestAnimationFrame_ :: forall a eff. Window -> Eff (dom :: DOM | eff) a -> Eff (dom :: DOM | eff) Request
requestAnimationFrame_ win =
    requestAnimationFrameWithTime_ win <<< const


-- | Request that the specified action be called on the next animation frame.
requestAnimationFrame :: forall a eff. Eff (dom :: DOM | eff) a -> Eff (dom :: DOM | eff) Request
requestAnimationFrame action =
    window >>= (flip requestAnimationFrameWithTime_) (const action)


-- | When it is time for the next animation frame, callback with the then-current
-- | time, and immediately execute the resulting effect.
requestAnimationFrameWithTime :: forall a eff. (Milliseconds -> Eff (dom :: DOM | eff) a) -> Eff (dom :: DOM | eff) Request
requestAnimationFrameWithTime func =
    window >>= (flip requestAnimationFrameWithTime_) func


-- | Like `requestAnimationFrameWithTime`, but you supply the `Window` object.
requestAnimationFrameWithTime_ :: forall a eff. Window -> (Milliseconds -> Eff (dom :: DOM | eff) a) -> Eff (dom :: DOM | eff) Request
requestAnimationFrameWithTime_ win func = do
    applyPolyfillIfNeeded win
    id <- requestAnimationFrameImpl win (func <<< Milliseconds)
    pure $ Request {id, win}


-- | Cancel a request.
cancelAnimationFrame :: forall eff. Request -> Eff (dom :: DOM | eff) Unit
cancelAnimationFrame (Request {win, id}) = cancelAnimationFrameImpl win id
