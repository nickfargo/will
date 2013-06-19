    state    = require 'state'

    Future   = require './future'
    Resolver = require './resolver'
    Promise  = require './promise'

    { isArray } = require 'util'

    { slice } = Array::

    module.exports =



## Deferral

A **deferral** is the prototypical implementation of a `Future`.

    class Deferral extends Future

      { later } = this


### Constructor

      constructor: ->

Stores one or more callbacks per resolution state. Items are upgraded to an
array if multiple callbacks are registered to a state.

        @_callbacks = null

        @_resolver = null
        @_promise = null
        @_context = null
        @_values = null



### Class functions


#### resolverToState

Creates a function that explicitly resolves a `Deferral` to the concrete final
`State` indicated by the enclosed `stateName`.

> This is used to define resolver methods, e.g. `accept` and `reject`, for a
  deferral’s `pending` state.

      @resolverToState = ( stateName ) -> ->
        @state().go stateName
        if callbacks = @_callbacks
          queue = callbacks[ stateName ]
          @_callbacks = null
        args = if arguments.length
        then @_values = slice.call arguments
        else @_values or = []
        { _context } = this
        if queue? then try
          if isArray queue
          then callback.apply _context, args for callback in queue
          else queue.apply _context, args
        return


#### invokeIff

Creates a function that invokes a `callback` on the next turn if and only if
the provided `stateName` matches the `boundStateName`.

> This is used to either asynchronously invoke or ignore callbacks supplied to
  `once` on a `Deferral` after it has reached a specific `resolved` substate.

      @invokeIff = ( boundStateName ) -> ( stateName, callback ) ->
        later.call @_context, callback, @_values if stateName is boundStateName



### Methods


#### getStateName

      getStateName: -> @state().name


#### resolver

      resolver: -> @_resolver or = new Resolver this


#### promise

      promise: -> @_promise or = new Promise this



### States

Defines concrete states [`pending`, `accepted`, `rejected`], and the method
overrides that describe a deferral’s specific behaviors within each state.

      state @::, 'abstract',


##### as, given

These methods always return `this`, but have no effect outside the `pending`
state, so a default implementation is defined here in the abstract root state.

        as: -> this
        given: -> this


#### unresolved

        unresolved: state 'abstract',

##### once

Accepts a `callback` to be invoked when `this` deferral is resolved to the
final `State` named by `stateName`.

          once: ( stateName, callback ) ->
            callbacks = @_callbacks or = {}
            if queue = callbacks[ stateName ]
              if isArray queue then queue.push callback
              else callbacks[ stateName ] = [ queue, callback ]
            else callbacks[ stateName ] = callback
            return


#### unresolved.pending

          pending: state 'initial', do =>
            { getThenFrom } = this

##### as

Prior to a deferral’s resolution, the `context` in which its callbacks will be
invoked can be set.

            as: ( @_context ) -> this

##### given

While a deferral is still `pending`, the arguments passed to its callbacks can
be predetermined. These will be overridden if any arguments are later provided
to a resolver method of `this` or a `Resolver`.

            given: ( values ) ->
              if values isnt undefined
                @_values = if values is null then null
                else if isArray values then values else [values]
              this

##### accept, reject

Because all concrete `State`s within the `resolved` domain are `final`, these
resolver methods only have effect while in the `pending` state.

            accept: @resolverToState 'accepted'
            reject: @resolverToState 'rejected'

##### resolve

Uses `value` to decide the fate of `this` deferral. If `value` is a futuroid or
“thenable”, its resolution is propagated to `this`.

            resolve: ( value ) ->
              return @reject new TypeError if value is this
              try if then_ = getThenFrom value then return then_.call value,
                ( next ) => ( if next is value then @accept else @resolve )
                  .apply this, arguments
                => @reject.apply this, arguments
              catch error then return @reject error
              @accept value


#### resolved

        resolved: state 'conclusive abstract',


#### resolved.completed

          completed: state 'conclusive abstract',


#### resolved.completed.accepted

            accepted: state 'final default',
              once: @invokeIff 'accepted'


#### resolved.completed.rejected

            rejected: state 'final',
              once: @invokeIff 'rejected'
