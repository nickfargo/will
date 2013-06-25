    Future = require './future'

    module.exports =



## Promise

A **promise** is an attenuation of a `Deferral`, where consumers are allowed
to observe the deferral’s state and react to its resolution, but are prohibited
from affecting it.

    class Promise extends Future

      allowed =
        getStateName: yes
        once: yes
        getValue: yes
        getValues: yes
        getContext: yes


### Constructor

      constructor: ( deferral ) ->
        @_apply = ( method, args ) ->
          return unless allowed[ method ]
          result = deferral[ method ].apply deferral, args
          result = this if result is deferral
          result



### Methods


#### promise

      promise: -> this


#### getStateName, once

Generated methods that reflect the attenuated `Deferral`.

      for name of allowed
        @::[ name ] = do ( name ) -> -> @_apply name, arguments
