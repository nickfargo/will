    module.exports =



## Resolver

A **resolver** is an attenuation of a `Deferral`, where consumers are allowed
only to attempt to affect the deferral’s resolution state, but are not given
any knowledge as to whether it is still `pending` or yet `resolved`.

    class Resolver

      methodNames = do ->
        object = {}
        object[ key ] = key for key in ['resolve', 'accept', 'reject']
        object

      constructor: ( deferral ) ->
        @_apply = ( method, args ) ->
          throw ReferenceError unless methodNames[ method ]?
          deferral[ method ].apply deferral, args
          this

      for name of methodNames
        @::[ name ] = do ( name ) -> -> @_apply name, arguments

      resolver: -> this
