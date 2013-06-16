    Future = require './future'

    module.exports =



## Promise

A **promise** is an attenuation of a `Deferral`, where consumers are allowed
to observe the deferral’s resolution and react to it, but are prohibited from
affecting it.

    class Promise extends Future

      allowed =
        getStateName: yes
        once: yes

      constructor: ( deferral ) ->
        @_apply = ( method, args ) ->
          throw ReferenceError unless allowed[ method ]
          result = deferral[ method ].apply deferral, args
          result = this if result is deferral
          result


      promise: -> this
      for name of allowed
        @::[ name ] = do ( name ) -> -> @_apply name, arguments
