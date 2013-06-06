    Future = require './future'

    module.exports =



## Promise

A **promise** is an attenuation of a `Deferral`, where consumers are allowed
only to observe the deferral’s resolution, and prohibited from affecting it.

    class Promise extends Future

      constructor: ( deferral ) ->
        @once = -> deferral.once.apply deferral, arguments
        @getState = -> deferral.state().name

      promise: -> this
