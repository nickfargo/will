    { isArray } = require './helpers'

    { slice } = Array::

    module.exports =



## Future

`Future` is an abstract base for classes such as `Deferral` or `Promise` that
produce or convey **futures**, objects that represent a value that may not yet
be available.

    class Future

      NULL_CONTEXT = do -> this


### Class functions


#### later

Arranges for `callback` to be invoked after this event-loop turn is finished.
(Does not pipe anything to a subsequent `Future`.)

      @later =
        if process? and "#{ process }" is '[object process]'
          ( callback, args ) ->
            args = [args] if args? and not isArray args
            process.nextTick => callback.apply this, args
            return
        else
          ( callback, args ) ->
            args = [args] if args? and not isArray args
            setTimeout ( => callback.apply this, args ), 1
            return


#### assimilate

Transforms an asynchronous function `fn` into a new function that returns a
type-equivalent `Promise`. Accommodates conventional node-style async methods
and callbacks. For functions whose callbacks should not expect a leading
`error` argument, the `infallible` flag may be set to `true`.

( [A], ( Error, [B] → void ) → void ) → ( [A] → Promise [B] )

if `infallible`:

( [A], ( [B] → void ) → void ) → ( [A] → Promise [B] )

      @assimilate = ( fn, infallible = no ) -> ->
        deferral = new Deferral
        args = slice.call arguments
        args.push ( error ) ->
          return deferral.accept.apply deferral, arguments if infallible
          unless error?
          then deferral.accept.apply deferral, slice.call arguments, 1
          else deferral.reject error
        fn.apply this, args
        deferral.promise()


#### isFuturoid

Determines whether a `value` is, or can be expected to act as, a `Future`.

*Aliases:* **resembles**, **resemblesFuture**

      @isFuturoid = ( value ) ->
        return null unless value
        return value if value instanceof Future or
          ( typeof value is 'object' or typeof value is 'function' ) and
          typeof value.then is 'function'
        null

      @resembles = @resemblesFuture = @isFuturoid


#### getThenFrom

Retrieves the `then` method function from a presumably `thenable` object.

      @getThenFrom = ( thenable ) ->
        if thenable? and ( typeof thenable is 'object' or
            typeof thenable is 'function' )
          method if typeof ( method = thenable.then ) is 'function'


#### accept

Boxes any value, or array of `values`, inside a new `accepted` `Deferral`.

> Useful for sending values to consumers that expect a `Future`-like interface.
  Also useful for type-disambiguation of objects that might otherwise be
  mistaken for a futuroid, e.g. anything that incidentally contains a `then`
  function.

*Aliases:* **of**, **wrap**

      @accept = ( values ) -> new Acceptance values
      @of = @wrap = @accept


#### reject

Boxes any value, or array of `values`, inside a new `rejected` `Deferral`.

> Useful for conveying a thrown exception to consumers that expect a
  `Future`-like interface.

      @reject: ( values ) -> new Rejection values



### Methods


#### then

      then: ( onAccepted, onRejected ) ->
        successor = new Deferral

        @once 'accepted', if typeof onAccepted is 'function'
        then ->
          try
            value = onAccepted.apply NULL_CONTEXT, arguments
            successor.resolve value if value isnt undefined
          catch error
            successor.reject error
        else ->
          successor.accept.apply successor, arguments

        @once 'rejected', if typeof onRejected is 'function'
        then ->
          try
            value = onRejected.apply NULL_CONTEXT, arguments
            successor.resolve value if value isnt undefined
          catch error
            successor.reject error
        else ->
          successor.reject.apply successor, arguments

        successor.promise()



### Declared forward

    Deferral   = require './deferral'
    Acceptance = require './acceptance'
    Rejection  = require './rejection'
