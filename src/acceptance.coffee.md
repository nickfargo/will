    state    = require '/lab/restate'

    Deferral = require './deferral'

    { slice } = Array::
    { isArray } = Array

    module.exports =



## Acceptance

An **acceptance** is a `Deferral` that is both initialized and inherently
finalized to its `accepted` state, effectively equivalent to an immediately
accepted proper `Deferral`.

See also: `Future.accept`, `Rejection`

    class Acceptance extends Deferral


### Constructor

Takes a value, or array of `values`, to be permanently enclosed by `this`
finalized `Deferral`.

      constructor: ( values ) ->
        @_values = if isArray values then slice.call values else [values]



### States

      state @::, resolved: completed: accepted: state 'initial final'