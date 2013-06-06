    module.exports =



## Resolver

A **resolver** is an attenuation of a `Deferral`, where consumers are allowed
only to attempt to affect the deferral’s resolution state, but are not given
any knowledge as to whether it is still `pending` or yet `resolved`.

    class Resolver

      methodNames = do ( o = {} ) ->
        o[k] = k for k in ['resolve', 'accept', 'reject']
        o

      constructor: ( deferral ) ->
        @_apply = ( method, args ) ->
          throw ReferenceError unless method of methodNames
          deferral[ method ].apply deferral, args
          this

      for name of methodNames
        @::[ name ] = do ( name ) -> -> @_apply name, arguments

      resolver: -> this
