    { isError } = require 'util'

    { isArray } = require 'omicron'
    { slice } = Array::

    Deferral   = null
    Acceptance = null
    Rejection  = null

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

      @later = later =
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


#### transform

Transforms an asynchronous function `fn` into a new function that returns a
type-equivalent `Promise`. Accommodates conventional node-style async methods
and callbacks.

> ( [A], ( Error, [B] → void ) → void ) → ( [A] → Promise [B] )

For asynchronous functions whose callbacks should not expect a leading `error`
argument, the `infallible` flag must be set to `true`.

> ( [A], ( [B] → void ) → void ) → ( [A] → Promise [B] )

      @transform = ( fn, infallible = no ) -> ->
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


#### resolve

Boxes a `value` or array of values inside a new already-`resolved` `Deferral`.

> Useful for sending values or propagating exceptions to consumers that expect
  a `Future`-like interface.

*Aliases:* **of**, **wrap**

      @resolve = ( value ) =>
        if ( isError value ) or ( isArray value ) and isError value[0]
        then @reject value
        else @accept value
      @of = @wrap = @resolve


#### accept

Boxes any `value`, or array of values, inside a new `accepted` `Deferral`.

      @accept = ( value ) -> new Acceptance value


#### reject

Boxes any `value`, or array of values, inside a new `rejected` `Deferral`.

      @reject = ( value ) -> new Rejection value


#### willBe

Returns a still-`pending` `Promise` for a closed `value`. The promise’s fate is
determined, but is not resolved or observable until after the end of this turn.

      @willBe = ( value ) ->
        deferral = new Deferral
        later if ( isError value ) or ( isArray value ) and isError value[0]
        then -> deferral.reject value
        else -> deferral.accept value
        deferral.promise()


#### join

Unifies the resolutions of an array of `futures` as a single `Promise`.

###### PARAMETERS

* `futures` : array — An ordered list whose elements are each a future, a
  future-returning thunk, or any other value to be resolved as a `Future`.

* `limit` : number — The returned promise will `accept` once this many of the
  substituent `futures` have resolved to the expected outcome as indicated by
  `positive`, or will `reject` once too many `futures` have resolved against
  the expected outcome.

* `positive` : boolean — Indicates the **polarity** of the `join` operation.
  When `true` (default), the returned promise will `accept` once a sufficient
  number of the joined `futures` are accepted/fulfilled, and `reject` once too
  many `futures` are rejected. When `false`, the resolutions of the returned
  promise are reversed: it will `reject` when enough `futures` are accepted
  and `accept` when too many `futures` are rejected.

###### RETURNS

`join` returns a `Promise` that will resolve with multiple arguments. Callbacks
that consume the promise may include parameters for:

* `results` : array — The list of resolved values from each of the `futures`.
  This list will include `undefined` values for `futures` that have not yet
  resolved by the time the returned promise is resolved (`limit < length`). The
  order of `results` will correspond with the order of the provided `futures`.

* `order` : array — A map of indices that indicate the temporal order in which
  each of the `futures` were resolved. The keys of `order` will correspond with
  the keys/indices of `results` and `futures`.

* `payload` : any — The value or error of the triggering element of `futures`
  which caused the `join` operation to resolve.

* `index` : number — The index of the triggering element of `futures`, such
  that `results[index]` is `payload`.

###### SEE ALSO

`all`, `none`, `any`, `notAny`

###### SOURCE

      @join = join = ( futures, limit, positive = yes ) ->
        throw TypeError unless ( length = futures?.length )?
        limit = length unless limit?
        throw RangeError unless 0 <= limit <= length
        if length is 0 or limit is 0
          return ( if positive then Rejection else Acceptance ).promise()

        { isFuturoid, resolve } = Future
        count = 0
        results = Array length
        order = []
        deferral = new Deferral

        for future, index in futures
          future = future() if typeof future is 'function'
          future = resolve future unless isFuturoid future

          expectation = do ( index ) -> ( payload ) ->
            results[ index ] = payload
            order.push index
            if ++count >= limit
              deferral.accept results, order, payload, index

          contingency = do ( index ) -> ( payload ) ->
            results[ index ] = payload
            order.push index
            if --length < limit
              deferral.reject results, order, payload, index

          if positive
          then onAccepted = expectation; onRejected = contingency
          else onAccepted = contingency; onRejected = expectation
          method = if future instanceof Future then 'bind' else 'then'
          future[ method ] onAccepted, onRejected

        deferral.promise()


#### all

Specializes `join` to the default case, where the returned `Promise` will
`accept` only after all `futures` are accepted (fulfilled), or will `reject`
immediately after any one of the `futures` is rejected.

      @all = ( futures ) -> join futures


#### none

Specializes `join` to define the polar opposite of `all`, where the returned
`Promise` will `accept` only after all `futures` are rejected, or will
`reject` immediately after any one of the `futures` is accepted.

      @none = ( futures ) -> join futures, null, no


#### any

Specializes `join` to define a **race**, where the returned `Promise` will
`accept` after any subset of `futures` of size `limit` are accepted, or will
`reject` after enough `futures` have rejected to preclude its acceptance.

      @any = ( limit, futures ) ->
        if futures is undefined then futures = limit; limit = 1
        join futures, limit


#### notAny

Specializes `join` to define a negative race, where the returned `Promise` will
`accept` after any subset of `futures` of size `limit` are rejected, or will
`reject` after enough `futures` have accepted to preclude its acceptance.

      @notAny = ( limit, futures ) ->
        if futures is undefined then futures = limit; limit = 1
        join futures, limit, no



### Methods


#### bind

      bind: ( onAccepted, onRejected ) ->
        if typeof onAccepted is 'function'
          @once 'accepted', -> try onAccepted.apply NULL_CONTEXT, arguments
        if typeof onRejected is 'function'
          @once 'rejected', -> try onRejected.apply NULL_CONTEXT, arguments
        return
      done: @::bind


#### then

      then: ( onAccepted, onRejected ) ->
        successor = new Deferral

        @once 'accepted', if typeof onAccepted is 'function'
        then ->
          try successor.resolve onAccepted.apply NULL_CONTEXT, arguments
          catch error then successor.reject error
        else ->
          successor.accept.apply successor, arguments

        @once 'rejected', if typeof onRejected is 'function'
        then ->
          try successor.resolve onRejected.apply NULL_CONTEXT, arguments
          catch error then successor.reject error
        else ->
          successor.reject.apply successor, arguments

        successor.promise()



### Forward imports

    Deferral   = require './deferral'
    Acceptance = require './acceptance'
    Rejection  = require './rejection'
