## Module DOM.RequestAnimationFrame

This module exposes a polyfilled `requestAnimationFrame` function.

#### `Request`

``` purescript
newtype Request
```

A request for a callback via `requestAnimationFrame`. You can supply this to
`cancelAnimationFrame` in order to cancel the request.

#### `requestAnimationFrame_`

``` purescript
requestAnimationFrame_ :: forall a eff. Window -> Eff (dom :: DOM | eff) a -> Eff (dom :: DOM | eff) Request
```

Request that the specified action be called on the next animation frame, specifying
the `Window` object.

#### `requestAnimationFrame`

``` purescript
requestAnimationFrame :: forall a eff. Eff (dom :: DOM | eff) a -> Eff (dom :: DOM | eff) Request
```

Request that the specified action be called on the next animation frame.

#### `requestAnimationFrameWithTime`

``` purescript
requestAnimationFrameWithTime :: forall a eff. (Milliseconds -> Eff (dom :: DOM | eff) a) -> Eff (dom :: DOM | eff) Request
```

When it is time for the next animation frame, callback with the then-current
time, and immediately execute the resulting effect.

#### `requestAnimationFrameWithTime_`

``` purescript
requestAnimationFrameWithTime_ :: forall a eff. Window -> (Milliseconds -> Eff (dom :: DOM | eff) a) -> Eff (dom :: DOM | eff) Request
```

Like `requestAnimationFrameWithTime`, but you supply the `Window` object.

#### `cancelAnimationFrame`

``` purescript
cancelAnimationFrame :: forall eff. Request -> Eff (dom :: DOM | eff) Unit
```

Cancel a request.


