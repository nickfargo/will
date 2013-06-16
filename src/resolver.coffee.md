    module.exports =



## Resolver

A **resolver** is an attenuation of a `Deferral`, where consumers are allowed
to attempt to affect the deferral’s resolution state, but can neither observe
its state nor react to its resolution.

    class Resolver

      allowed =
        as: yes
        given: yes
        resolve: yes
        accept: yes
        reject: yes


### Constructor

      constructor: ( deferral ) ->
        @_apply = ( method, args ) ->
          return unless allowed[ method ]
          deferral[ method ].apply deferral, args
          this



### Methods


#### resolver

      resolver: -> this


#### Generated methods

      for name of allowed
        @::[ name ] = do ( name ) -> -> @_apply name, arguments
