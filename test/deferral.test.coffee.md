    { expect } = require 'chai'
    { Future, Deferral } = require '../'
    { later, willBe } = Future
    { nextTick } = process

    log = -> console.log.apply log, arguments



    describe "Deferral:", ->

      describe "resolution", ->

        describe "specific resolutions / concrete states", ->

          it "accepts", ( end ) ->
            d = new Deferral
            d.once 'accepted', -> do end
            nextTick -> do d.accept

          it "rejects", ( end ) ->
            d = new Deferral
            d.once 'rejected', -> do end
            nextTick -> do d.reject

        describe "generalized resolutions / abstract states", ->

          it "implies completed when accepted", ( end ) ->
            d = new Deferral
            d.state('completed').virtualize( d.state() ).realize()
            d.state('completed').on 'enter', -> do end
            nextTick -> do d.accept

          it "implies completed when rejected", ( end ) ->
            d = new Deferral
            d.state('completed').virtualize( d.state() ).realize()
            d.state('completed').on 'enter', -> do end
            nextTick -> do d.reject

        describe "enforced asynchronicity", ->
          it "responds post-hoc on a future turn", ( end ) ->
            d = new Deferral
            finished = no
            do d.accept
            d.once 'rejected', -> end new Error
            d.once 'accepted', -> finished = yes; do end
            end new Error if finished

        describe "finality", ->
          it "cannot revert state", ( end ) ->
            d = new Deferral
            do d.accept
            do d.reject
            d.once 'rejected', -> end throw Error
            d.once 'accepted', -> do end

        describe "callback context and arguments", ->
          it "recognizes context", ( end ) ->
            c = {}
            d = new Deferral
            d.as c
            d.once 'accepted', ->
              expect( this ).to.equal c
              do end
            nextTick -> do d.accept

          it "recognizes preset arguments", ( end ) ->
            d = new Deferral
            d.given [1,2,3]
            d.once 'accepted', ( a, b, c ) ->
              expect( a ).to.equal 1
              expect( b ).to.equal 2
              expect( c ).to.equal 3
              do end
            nextTick -> do d.accept

          it "overrides preset arguments", ( end ) ->
            d = new Deferral
            d.given [1,2,3]
            d.once 'accepted', ( a, b, c ) ->
              expect( a ).to.equal 4
              expect( b ).to.equal 5
              expect( c ).to.equal undefined
              do end
            nextTick -> d.accept 4, 5

          it "erases preset arguments", ( end ) ->
            d = new Deferral
            d.given [1,2,3]
            d.given null
            d.once 'accepted', ( a, b, c ) ->
              expect( a ).to.equal undefined
              expect( b ).to.equal undefined
              expect( c ).to.equal undefined
              do end
            nextTick -> do d.accept

          it "prohibits post-hoc mutation", ( end ) ->
            d = new Deferral
            d.as( c1 = name:'c1' ).given([1,2]).accept()
            d.as( c2 = name:'c2' ).given([3,4]).once 'accepted', ( a, b ) ->
              expect( this ).to.equal c1
              expect( a ).to.equal 1
              expect( b ).to.equal 2
              do end




      describe "attenuation", ->

        describe "read-only (promises)", ->

        describe "write-only (resolvers)", ->


      describe "propagation", ->

        describe "chaining", ->
          reject = ( reason ) ->
            d = new Deferral
            nextTick -> d.reject reason
            d.promise()

          double = ( x ) -> willBe x + x
          square = ( x ) -> willBe x * x
          quadruple = ( x ) ->
            willBe( x )
            .then( double )
            .then( double )

          increment = ( x ) -> async x + 1


          it "chains async, sync, and composite async functions", ( end ) ->
            result = willBe( 3 )
              .then( double )
              .then( square )
              .then( quadruple )
              .then( Math.sqrt )
              .once 'accepted', ( x ) ->
                expect( x ).to.equal 12
                do end
            expect( result ).to.equal undefined

          it "handles and recovers from rejections and exceptions", ( end ) ->
            result = willBe( err = new Error )
              .then( -> )
              .then( null, ( reason ) ->
                expect( reason ).to.equal err
                willBe( 3 ) )
              .then( double )
              .then( reject )
              .then( -> )
              .then( null, ( reason ) ->
                expect( reason ).to.equal 6
                willBe( 4 ) )
              .then( -> throw "a tantrum" )
              .then( -> )
              .then( null, ( reason ) ->
                expect( reason ).to.equal "a tantrum"
                willBe( 5 ) )
              .then( square )
              .once 'accepted', ( x ) ->
                expect( x ).to.equal 25
                do end
            expect( result ).to.equal undefined


      describe "implementation", ->

        it "dumps all callbacks after resolution", ( end ) ->
          d = new Deferral
          d.once 'accepted', ->
            expect( d._callbacks ).to.equal null
            do end
          expect( d._callbacks ).not.to.equal null
          nextTick -> do d.accept

