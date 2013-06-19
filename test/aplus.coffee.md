    tests = require 'promises-aplus-tests'

    { Deferral } = require '../'
    { accept, reject } = Deferral



https://github.com/promises-aplus/promises-tests


### Adapters

In order to test your promise library, you must expose a very minimal adapter interface. These are written as Node.js
modules with a few well-known exports:

- `fulfilled(value)`: creates a promise that is already fulfilled with `value`.
- `rejected(reason)`: creates a promise that is already rejected with `reason`.
- `pending()`: creates an object consisting of `{ promise, fulfill, reject }`:
  - `promise` is a promise that is currently in the pending state.
  - `fulfill(value)` moves the promise from the pending state to a fulfilled state, with fulfillment value `value`.
  - `reject(reason)` moves the promise from the pending state to the rejected state, with rejection reason `reason`.

The `fulfilled` and `rejected` exports are actually optional, and will be automatically created by the test runner using
`pending` if they are not present. But, if your promise library has the capability to create already-fulfilled or
already-rejected promises, then you should include these exports, so that the test runner can provide you with better
code coverage and uncover any bugs in those methods.

Note that the tests will never pass a promise or a thenable as a fulfillment value. This allows promise implementations
that only have "resolve" functionality, and don't allow direct fulfillment, to implement the `pending().fulfill` and
`fulfilled`, since fulfill and resolve are equivalent when not given a thenable.

Finally, note that none of these functions, including `pending().fulfill` and `pending().reject`, should throw
exceptions. The tests are not structured to deal with that, and if your implementation has the potential to throw
exceptions—e.g., perhaps it throws when trying to resolve an already-resolved promise—you should wrap direct calls to
your implementation in `try`/`catch` when writing the adapter.


    describe "Promises/A+ tests", -> tests.mocha adapter =
      fulfilled: ( value ) -> accept value
      rejected: ( reason ) -> reject reason
      pending: ->
        deferral = new Deferral
        promise: deferral.promise()
        fulfill: ( value ) -> deferral.accept value
        reject: ( reason ) -> deferral.reject reason
