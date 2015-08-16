## Module DOM.RequestAnimationFrame

This module exposes a polyfilled `requestAnimationFrame` function.

#### `requestAnimationFrame_`

``` purescript
requestAnimationFrame_ :: forall a eff. Window -> Eff (dom :: DOM | eff) a -> Eff (dom :: DOM | eff) Unit
```

Request the specified action be called on the next animation frame, specifying the `Window` object.

#### `requestAnimationFrame`

``` purescript
requestAnimationFrame :: forall a eff. Eff (dom :: DOM | eff) a -> Eff (dom :: DOM | eff) Unit
```

Request the specified action be called on the next animation frame.


