## Future

`Future` is an abstract base for classes such as `Deferral` or `Promise` that
produce or convey **futures**, objects that represent a value that is not yet
available.

    class Future

      { slice } = Array::
      noContext = do -> this


### Class functions


#### wrap

Boxes any value, or array of `values`, inside a new `accepted` `Deferral`.

> This operation is useful for interacting with consumers that strictly expect
  values to be delivered asynchronously via a `Future`-like interface.

      @wrap: ( values ) -> new Acceptance values


#### later

Arranges for `callback` to be invoked after this event-loop turn is finished.
(Does not pipe anything to a subsequent `Future`.)

      @later:
        if process? and "#{ process }" is '[object process]'
          ( callback ) ->
            process.nextTick => callback.apply this, arguments
            return
        else
          ( callback ) ->
            setTimeout ( => callback.apply this, arguments ), 1
            return


#### assimilator

Transforms an asynchronous function `fn` into a new function that returns a
type-equivalent `Promise`. Accommodates conventional node-style async methods
and callbacks.

( [A], ( Error, [B] → void ) → void ) → ( [A] → Promise [B] )

      @assimilator: ( fn ) -> ->
        deferral = new Deferral
        args = slice.call arguments
        args.push ( error ) ->
          unless error
          then deferral.accept.apply deferral, slice.call arguments, 1
          else deferral.reject error
        fn.apply this, args
        deferral.promise()


#### isFuturoid

Determines whether a `value` is, or can be expected to act as, a `Future`.

*Aliases:* **resembles**, **resemblesFuture**

      @isFuturoid: ( value ) ->
        return null unless value
        return value if value instanceof Future or
          ( typeof value is 'object' or typeof value is 'function' ) and
          typeof value.then is 'function'
        null

      @resembles = @resemblesFuture = @isFuturoid


#### getThenFrom

Retrieves the `then` method function from a presumably `thenable` object.

      @getThenFrom: ( thenable ) ->
        if thenable? and ( typeof thenable is 'object' or
            typeof thenable is 'function' )
          method if typeof ( method = thenable.then ) is 'function'



### Methods


#### then

      then: ( onAccepted, onRejected ) ->
        successor = new Deferral

        @once 'accepted', if typeof onAccepted is 'function'
        then ->
          try
            value = onAccepted.apply noContext, arguments
            successor.resolve value if value isnt undefined
          catch error
            successor.reject error
        else ->
          successor.accept.apply successor, arguments

        @once 'rejected', if typeof onRejected is 'function'
        then ->
          try
            value = onRejected.apply noContext, arguments
            successor.resolve value if value isnt undefined
          catch error
            successor.reject error
        else ->
          successor.reject.apply successor, arguments

        successor.promise()
