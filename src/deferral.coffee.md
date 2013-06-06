    state    = require '../../restate'

    Future   = require './future'
    Resolver = require './resolver'
    Promise  = require './promise'

    { isArray } = require './helpers'

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

        @_callbacks = accepted: null, rejected: null

        @_resolver = null
        @_promise = null
        @_context = null
        @_values = null



### Class functions


#### resolverToState

Creates a function that explicitly resolves a `Deferral` to the concrete final
`State` indicated by the enclosed `stateName`. This is used to define resolver
methods, e.g. `accept` and `reject`, for a deferral’s `pending` state.

      @resolverToState = ( stateName ) -> ->
        queue = @_callbacks[ stateName ]
        @_callbacks = null
        args = if arguments.length
        then @_values = slice.call arguments
        else @_values or = []
        { _context } = this
        if queue? then try
          if isArray queue
          then callback.apply _context, args for callback in queue
          else queue.apply _context, args
        @state().go stateName
        return


#### invokeIff

Creates a function that invokes a `callback` on the next turn if and only if
the provided `stateName` matches the `boundStateName`. This is used to either
asynchronously invoke or ignore such callbacks after a `Deferral` has reached a
specific `resolved` substate.

      @invokeIff = ( boundStateName ) -> ( stateName, callback ) ->
        later.call this, callback, @_values if stateName is boundStateName



### Methods


#### resolver

      resolver: -> @_resolver or = new Resolver this


#### promise

      promise: -> @_promise or = new Promise this



### States

Defines concrete states [`pending`, `accepted`, `rejected`], and the method
overrides that describe a deferral’s specific behaviors within each state.

      state @::, 'abstract',


#### pending

        pending: state 'initial', do =>
          { getThenFrom } = this

##### accept, reject

Because all concrete `State`s within the `resolved` domain are `final`, these
resolver methods only have effect while in the `pending` state.

          accept: @resolverToState 'accepted'
          reject: @resolverToState 'rejected'

##### resolve

Uses `value` to decide the fate of `this` deferral. If `value` may be assumed
to be a `Future`-like “thenable”, its resolution is propagated to `this`.

          resolve: ( value ) ->
            try if then_ = getThenFrom value then return then_.call value,
              => @resolve.apply this, arguments
              => @reject.apply this, arguments
            catch error then return @reject error
            @accept value

##### once

Accepts a `callback` to be invoked when `this` deferral is resolved to the
final `State` named by `stateName`.

          once: ( stateName, callback ) ->
            { _callbacks } = this
            return unless stateName of _callbacks
            if target = _callbacks[ stateName ]
              if isArray target then target.push callback
              else _callbacks[ stateName ] = [ target, callback ]
            else _callbacks[ stateName ] = callback
            return


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
