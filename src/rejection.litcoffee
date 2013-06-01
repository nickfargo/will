## Rejection

A **rejection** is a `Deferral` that is both initialized and inherently
finalized to its `rejected` state, effectively equivalent to an immediately
rejected proper `Deferral`.

Such a “pre-resolved” future is useful as the product of a coersion operation
that presents arbitrary values as a `Future`, for the benefit of consumers that
expect to receive values of that type.

See also: `Acceptance`

    class Rejection extends Deferral


### Constructor

Takes a value, or array of `values`, to be permanently enclosed by `this`
finalized `Deferral`.

      constructor: ( values ) ->
        @_values = if isArray values then values.slice() else [values]



### States

      state @::, resolved: completed: rejected: state 'initial final'
