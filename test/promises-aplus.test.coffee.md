    tests = require 'promises-aplus-tests'

    { Deferral } = require '../'
    { accept, reject } = Deferral



    describe "Promises/A+ tests", -> tests.mocha adapter =
      fulfilled: ( value ) -> accept value
      rejected: ( reason ) -> reject reason
      pending: ->
        deferral = new Deferral
        promise: deferral.promise()
        fulfill: ( value ) -> deferral.accept value
        reject: ( reason ) -> deferral.reject reason



https://github.com/promises-aplus/promises-tests
