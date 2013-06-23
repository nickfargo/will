    { expect } = require 'chai'
    { Future } = require '../'
    { later, willBe } = Future
    { nextTick } = process

    log = -> console.log.apply log, arguments



    describe.only "Future:", ->

      describe "join", ->
        { join, all, none, any, notAny } = Future

        it "accepts only after all futures are accepted", ( end ) ->
          join( willBe i for i in [0..4] ).then ( results ) ->
            expect( results ).to.be.instanceof Array
            do end

        it "rejects immediately once any future is rejected", ( end ) ->
          futures = [
            willBe 0
            willBe new Error "rejection"
            willBe 2
          ]
          join( futures ).then null, ( results, order, error, index ) ->
            expect( futures[0].getStateName() ).to.equal 'accepted'
            expect( futures[1].getStateName() ).to.equal 'rejected'
            expect( futures[2].getStateName() ).to.equal 'pending'
            expect( error?.message ).to.equal "rejection"
            expect( index ).to.equal 1
            expect( results[0] ).to.equal 0
            expect( results[1] ).to.equal error
            expect( results[2] ).to.equal undefined
            do end

        it "preserves order of received array in returned results", ( end ) ->
          futures = new Array 5
          futures[i] = willBe i for i in [4..0] by -1
          join( futures ).then ( results ) ->
            ordered = yes
            ( ordered = no; break ) for i in results when results[i] isnt i
            expect( ordered ).to.equal yes
            do end

        describe "specializations:", ->

          describe "all", ->

            it "behaves like unqualified `join`", ->

          describe "none", ->

            it "accepts only after all futures are rejected", ( end ) ->
              none( willBe new Error for i in [0..4] ).then ( results ) ->
                expect( results ).to.be.instanceof Array
                do end

            it "rejects immediately once any future is accepted", ( end ) ->
              futures = [
                willBe new Error "rejection"
                willBe "acceptance"
                willBe new Error
              ]
              none( futures ).then null, ( results, order, value, index ) ->
                expect( futures[0].getStateName() ).to.equal 'rejected'
                expect( futures[1].getStateName() ).to.equal 'accepted'
                expect( futures[2].getStateName() ).to.equal 'pending'
                expect( value ).to.equal "acceptance"
                expect( index ).to.equal 1
                expect( results[0]?.message ).to.equal "rejection"
                expect( results[1] ).to.equal value
                expect( results[2] ).to.equal undefined
                do end

          describe "any", ->

            it "accepts immediately after one future is accepted", ( end ) ->
              futures = ( willBe i for i in [0..4] )

              any( futures ).then ( results, order, value, index ) ->
                expect( results ).to.be.instanceof Array
                expect( results[0] ).to.equal value
                expect( value ).to.equal 0
                expect( index ).to.equal 0
                expect( results.length ).to.equal 5
                expect( results[1] ).to.equal undefined
                expect( results[2] ).to.equal undefined
                expect( results[3] ).to.equal undefined
                expect( results[4] ).to.equal undefined
                do end

            it "accepts after multiple futures are accepted", ( end ) ->
              futures = ( willBe i for i in [0..4] )

              any( 3, futures ).then ( results, order, value, index ) ->
                expect( results ).to.be.instanceof Array
                expect( results[2] ).to.equal value
                expect( value ).to.equal 2
                expect( index ).to.equal 2
                expect( results.length ).to.equal 5
                expect( results[0] ).to.equal 0
                expect( results[1] ).to.equal 1
                expect( results[2] ).to.equal 2
                expect( results[3] ).to.equal undefined
                expect( results[4] ).to.equal undefined
                do end

            it "rejects immediately once acceptance is impossible", ( end ) ->
              promise = any 4, [
                willBe 0
                willBe e1 = new Error
                willBe 2
                willBe e2 = new Error  # <-- acceptance precluded here
                willBe 4
              ]
              promise.then null, ( results, order, value, index ) ->
                expect( results ).to.be.instanceof Array
                expect( results[3] ).to.equal value
                expect( value ).to.equal e2
                expect( index ).to.equal 3
                expect( results.length ).to.equal 5
                expect( results[0] ).to.equal 0
                expect( results[1] ).to.equal e1
                expect( results[2] ).to.equal 2
                expect( results[3] ).to.equal e2
                expect( results[4] ).to.equal undefined
                do end

          describe "notAny", ->

            it "accepts immediately once rejection is impossible", ( end ) ->
              promise = notAny 3, [
                willBe e1 = new Error
                willBe e2 = new Error
                willBe 2
                willBe e3 = new Error  # <-- acceptance assured here
                willBe 4
              ]
              promise.then ( results, order, value, index ) ->
                expect( results ).to.be.instanceof Array
                expect( results.length ).to.equal 5
                expect( results[3] ).to.equal value
                expect( index ).to.equal 3
                expect( value ).to.equal e3
                expect( results[0] ).to.equal e1
                expect( results[1] ).to.equal e2
                expect( results[2] ).to.equal 2
                expect( results[3] ).to.equal e3
                expect( results[4] ).to.equal undefined
                do end

            it "rejects immediately once acceptance is impossible", ( end ) ->
              promise = notAny 3, futures = [
                willBe 0
                willBe e1 = new Error
                willBe 2
                willBe 3  # <-- acceptance precluded, too many futures accepted
                willBe e2 = new Error
              ]
              promise.then null, ( results, order, value, index ) ->
                expect( results ).to.be.instanceof Array
                expect( results.length ).to.equal 5
                expect( results[3] ).to.equal value
                expect( index ).to.equal 3
                expect( value ).to.equal 3
                expect( results[0] ).to.equal 0
                expect( results[1] ).to.equal e1
                expect( results[2] ).to.equal 2
                expect( results[3] ).to.equal 3
                expect( results[4] ).to.equal undefined
                do end
