    state = require '../../restate'

    Deferral = require './deferral'

    { slice } = Array::
    { isArray } = require 'util'

    module.exports =



## Rejection

An explicit **rejection** is a `Deferral` that is both initialized and
inherently finalized to its `rejected` state, equivalent in effect to an
immediately rejected proper `Deferral`.

See also: `Future.reject`, `Acceptance`

    class Rejection extends Deferral


### Constructor

Takes a value, or array of `values`, to be permanently enclosed by `this`
finalized `Deferral`.

      constructor: ( values ) ->
        @_values = if isArray values then slice.call values else [values]



### States

      state @::, resolved: completed: rejected: state 'initial final'
