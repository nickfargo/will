## Helpers


#### isArray

    isArray = Array.isArray or do ( toString = Object::toString ) ->
      ( object ) -> object? and toString.call( object ) is '[object Array]'



    module.exports = {
      isArray
    }
