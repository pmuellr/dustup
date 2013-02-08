# Licensed under the Tumbolia Public License. See footer for details.

assert = require "assert"

dustup = require "../lib/dustup"

Bolt = dustup.Bolt

#-------------------------------------------------------------------------------
suite __filename, ->

    #---------------------------------------------------------------------------
    test "two simple bolts", (done) ->

        boltA = new Bolt
            outlets:
                a: "outlet a"

        boltB = new Bolt
            inlets:
                b: (data) ->
                    assert.equal data, "is it working"
                    done()

        Bolt.connect
            a: boltA
            b: boltB

        boltA.emit a: "is it working"

    #---------------------------------------------------------------------------
    test "three simple bolts", (done) ->

        boltA = new Bolt
            outlets:
                a: "outlet a"

        boltB = new Bolt
            inlets:
                ba: (data) -> @emit bc: "#{data}?"
            outlets:
                bc: "outlet bc"

        boltC = new Bolt
            inlets:
                c: (data) ->
                    assert.equal data, "is it working?"
                    done()

        Bolt.connect a:  boltA, ba: boltB
        Bolt.connect bc: boltB, c:  boltC

        boltA.emit a: "is it working"

    #---------------------------------------------------------------------------
    test "three simple bolts, switched connect spec order", (done) ->

        boltA = new Bolt
            outlets:
                a: "outlet a"

        boltB = new Bolt
            inlets:
                ba: (data) -> @emit bc: "#{data}?"
            outlets:
                bc: "outlet bc"

        boltC = new Bolt
            inlets:
                c: (data) ->
                    assert.equal data, "is it working?"
                    done()

        Bolt.connect ba: boltB, a:  boltA
        Bolt.connect c:  boltC, bc: boltB

        boltA.emit a: "is it working"

    #---------------------------------------------------------------------------
    test "error outlet", (done) ->

        boltA = new Bolt
            name: "boltA"
            outlets:
                a: "outlet a"

        boltB = new Bolt
            name: "boltB"
            inlets:
                b: (data) ->
                    throw new Error("boo")
                error: (err) ->
                    assert.equal err.outletBolt,    boltA
                    assert.equal err.outletName,    "a"
                    assert.equal err.inletBolt,     boltB
                    assert.equal err.inletName,     "b"
                    assert.equal err.data,          "is it working"
                    assert.equal err.error.message, "boo"
                    done()

        Bolt.connect
            a: boltA
            b: boltB

        boltA.emit a: "is it working"

    #---------------------------------------------------------------------------
    test "as classes", (done) ->

        class BoltX extends Bolt
            constructor: (@prefix, spec) ->
                super spec

        boltA = new Bolt
            outlets:
                o: "outlet o"

        boltB = new BoltX "b: ",
            inlets:
                i: (data) -> @emit o: "#{@prefix}#{data}"
            outlets:
                o: "outlet o"

        boltC = new BoltX "c: ",
            inlets:
                i: (data) -> @emit o: "#{@prefix}#{data}"
            outlets:
                o: "outlet o"

        boltD = new Bolt
            inlets:
                i: (data) ->
                    assert.equal data, "c: b: is it working"
                    done()

        Bolt.connect o: boltA, i: boltB
        Bolt.connect o: boltB, i: boltC
        Bolt.connect o: boltC, i: boltD

        boltA.emit o: "is it working"

    #---------------------------------------------------------------------------
    test "disconnect", (done) ->

        boltB_b_active = false

        boltA = new Bolt
            outlets:
                a: "outlet a"

        boltB = new Bolt
            inlets:
                b: (data) ->
                    boltB_b_active = true

        Bolt.connect
            a: boltA
            b: boltB

        Bolt.disconnect
            a: boltA
            b: boltB

        boltA.emit a: "is it working"

        check = ->
            if boltB_b_active
                done new Error()
                return

            done()

        setTimeout check, 500


#-------------------------------------------------------------------------------
# Copyright (c) 2013 Patrick Mueller
#
# Tumbolia Public License
#
# Copying and distribution of this file, with or without modification, are
# permitted in any medium without royalty provided the copyright notice and
# this notice are preserved.
#
# TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#   0. opan saurce LOL
#-------------------------------------------------------------------------------