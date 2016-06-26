module Test.Main where


import DOM.RequestAnimationFrame
import Control.Monad.Aff (Aff, later, later')
import Control.Monad.Aff.Console (logShow)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Now (now, NOW)
import Control.Monad.Eff.Ref (REF, newRef, writeRef, readRef, modifyRef)
import DOM (DOM)
import DOM.HTML.Types (Window)
import Data.DateTime.Instant (unInstant, Instant)
import Data.Time.Duration (Milliseconds(Milliseconds))
import Prelude (void, Unit, bind, (>>=), ($), (<$>), negate, (>), (+), (-), (==), (<>), show)
import Test.Unit (test)
import Test.Unit.Assert (assert)
import Test.Unit.Console (TESTOUTPUT)
import Test.Unit.Main (runTest)


-- The requestAnimationFrame polyfill technically works on Node, so we supply a
-- fake window for testing. We could expose the actual functionality on Node, but
-- it doesn't really make sense, since why tie yourself to 60 FPS?
--
-- This means that we're basically testing the polyfill, but that should be fine,
-- since we're pretty confident that the native functions will behave as the
-- polyfill does.
--
-- We do this effectfully, because we want to be able to control when we have a
-- a fresh polyfill ... otherwise, we don't know how soon the next animation frame
-- might arrive (since the previous test would affect the next test).
foreign import fakeWindow :: forall eff. Eff (dom :: DOM | eff) Window


logTime :: forall eff. Aff (now :: NOW, console :: CONSOLE | eff) Unit
logTime = (liftEff now) >>= logShow


elapsed :: Instant -> Instant -> Milliseconds
elapsed a b =
    (unInstant b) - (unInstant a)


main :: Eff (now :: NOW, dom :: DOM, ref :: REF, console :: CONSOLE, testOutput :: TESTOUTPUT) Unit
main =
    runTest do
        test "Basic" do
            raf <- liftEff $ requestAnimationFrame_ <$> fakeWindow
            testVar <- liftEff $ newRef 0

            liftEff $
                raf (writeRef testVar 1)

            later' 20 do
                result <- liftEff (readRef testVar)
                assert "Didn't execute after 20 millis" (result == 1)

        test "Doesn't execute immediately" do
            raf <- liftEff $ requestAnimationFrame_ <$> fakeWindow
            testVar <- liftEff $ newRef 0

            liftEff $ raf (writeRef testVar 1)

            initialResult <- liftEff $ readRef testVar
            assert "Callback immediately executed" (initialResult == 0)

            later' 20 do
                result <- liftEff (readRef testVar)
                assert "Hasn't executed after 20 millis" (result == 1)

        test "Doesn't execute too soon" do
            raf <- liftEff $ requestAnimationFrame_ <$> fakeWindow
            testVar <- liftEff $ newRef 0

            started <- liftEff now
            liftEff $ raf (writeRef testVar 1)

            later do
                result <- liftEff (readRef testVar)
                ended <- liftEff now
                assert
                    ( "Callback executed too soon. " <>
                      "But, this could fail sporadically, if it took 16 millis. " <>
                      "We checked after " <> show (elapsed started ended) <>
                      ", and we got the result: " <> show result
                    )
                    (result == 0)

            later' 20 do
                result <- liftEff (readRef testVar)
                assert "Hasn't executed after 20 millis" (result == 1)

        test "Cancelling" do
            raf <- liftEff $ requestAnimationFrame_ <$> fakeWindow
            testVar <- liftEff $ newRef 0

            request <- liftEff $
                raf (writeRef testVar 1)

            liftEff $
                cancelAnimationFrame request

            later' 20 do
                result <- liftEff (readRef testVar)
                assert "Executed even though we canceled. This can fail sporadically, depending on timing." (result == 0)

        test "Cancelling a little later" do
            raf <- liftEff $ requestAnimationFrame_ <$> fakeWindow
            testVar <- liftEff $ newRef 0

            request <- liftEff $
                raf (writeRef testVar 1)

            later' 5 $ liftEff $
                cancelAnimationFrame request

            later' 20 do
                result <- liftEff (readRef testVar)
                assert "Executed even though we canceled. This can fail sporadically, depending on timing." (result == 0)

        test "Basically is called just once" do
            raf <- liftEff $ requestAnimationFrame_ <$> fakeWindow
            testVar <- liftEff $ newRef 0

            liftEff $
                raf (modifyRef testVar (_ + 1))

            later' 100 do
                result <- liftEff (readRef testVar)
                assert ("We were called " <> show result <> " times, rather than once.") (result == 1)

        test "Chaining requestAnimationFrame" do
            raf <- liftEff $ requestAnimationFrame_ <$> fakeWindow
            testVar <- liftEff $ newRef 0

            liftEff $ raf do
                writeRef testVar 1
                void $ raf do
                    writeRef testVar 2
                    void $ raf do
                        writeRef testVar 3

            initialResult <- liftEff $ readRef testVar
            assert "Callback immediately executed" (initialResult == 0)

            later do
                result <- liftEff (readRef testVar)
                assert ("Callback executed too soon.") (result == 0)

            later' 10 do
                result <- liftEff (readRef testVar)
                assert ("Callback executed after 10 millis.") (result == 0)

            later' 20 do
                result <- liftEff (readRef testVar)
                assert ("One raf should have executed.") (result == 1)

            later' 20 do
                result <- liftEff (readRef testVar)
                assert ("Second raf should have executed.") (result == 2)

            later' 20 do
                result <- liftEff (readRef testVar)
                assert ("Third raf should have executed.") (result == 3)

        test "Timed" do
            rafWithTime <- liftEff $ requestAnimationFrameWithTime_ <$> fakeWindow
            testVar <- liftEff $ newRef (-20.0)

            liftEff $
                rafWithTime (\(Milliseconds millis) ->
                    writeRef testVar millis
                )

            later' 20 do
                result <- liftEff $ readRef testVar
                assert ("The time value " <> show result <> " wasn't sane") (result > 0.0)

        test "Timed is called just once" do
            rafWithTime <- liftEff $ requestAnimationFrameWithTime_ <$> fakeWindow
            testVar <- liftEff $ newRef (0)

            liftEff $
                rafWithTime (\(Milliseconds millis) ->
                    modifyRef testVar (_ + 1)
                )

            later' 100 do
                result <- liftEff $ readRef testVar
                assert ("We were called " <> show result <> " times, rather than once.") (result == 1)

        test "Multiple rafs get the same time in the callback" do
            rafWithTime <- liftEff $ requestAnimationFrameWithTime_ <$> fakeWindow
            testVar1 <- liftEff $ newRef (0.0)
            testVar2 <- liftEff $ newRef (1.0)

            liftEff do
                rafWithTime (\(Milliseconds millis) ->
                    writeRef testVar1 millis
                )

            later' 5 $ liftEff do
                rafWithTime (\(Milliseconds millis) ->
                    writeRef testVar2 millis
                )

            later' 25 do
                result1 <- liftEff $ readRef testVar1
                result2 <- liftEff $ readRef testVar2

                assert ("Callbacks should be given the same time") (result1 == result2)
