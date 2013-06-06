    Future = require './future'

    module.exports =



## Promise

A **promise** is an attenuation of a `Deferral`, where consumers are allowed
to observe the deferral’s resolution and react to it, but are prohibited from
affecting it.

    class Promise extends Future

      constructor: ( deferral ) ->
        @once = -> deferral.once.apply deferral, arguments
        @getState = -> deferral.state().name

      promise: -> this