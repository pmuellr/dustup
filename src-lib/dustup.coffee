# Licensed under the Tumbolia Public License. See footer for details.

util = require "util"

dustup = exports

#-------------------------------------------------------------------------------
dustup.Bolt  = class Bolt

    #---------------------------------------------------------------------------
    @connect: (lets) ->
        [inlet, outlet] = calculateInAndOut lets

        outlet.addInlet inlet

    #---------------------------------------------------------------------------
    @disconnect: (lets) ->
        [inlet, outlet] = calculateInAndOut lets

        outlet.removeInlet inlet

    #---------------------------------------------------------------------------
    @nextTick: (func) ->
        process.nextTick func

    #---------------------------------------------------------------------------
    constructor: (letSpec) ->
        @lets  = {}
        @name  = letSpec?.name

        addInletsToBolt  @, letSpec?.inlets
        addOutletsToBolt @, letSpec?.outlets

    #---------------------------------------------------------------------------
    emit: (name, data) ->
        if arguments.length is 1
            object = name
            for own name, data of object
                @emit name, data
            return @

        outlet = @lets[name]

        if !(outlet instanceof Outlet)
            throw new TypeError "no outlet named '#{name}'"

        outlet.emit(data)

        return @

    #---------------------------------------------------------------------------
    toString: ->
        return "[Bolt <unnamed>]" if !@name?
        return "[Bolt #{@name}]"

#---------------------------------------------------------------------------
addInletsToBolt = (bolt, inlets) ->
    return if !inlets?

    for own name, reader of inlets
        if typeof reader != "function"
            throw new TypeError "expecting a function for inlet property '#{name}'"

        bolt.lets[name] = new Inlet bolt, name, reader

    return

#---------------------------------------------------------------------------
addOutletsToBolt = (bolt, outlets) ->
    return if !outlets?

    for own name, desc of outlets
        bolt.lets[name] = new Outlet bolt, name, desc

    return

#-------------------------------------------------------------------------------
calculateInAndOut = (lets) ->

    lets = for own name, bolt of lets
        if !(bolt instanceof Bolt)
            throw new TypeError "expecting a bolt value for property '#{name}'"

        {name, bolt}

    if lets.length != 2
        throw new TypeError "expecting two properties in the connection spec"

    [letA, letB] = lets

    letAin = letA.bolt.lets[letA.name] instanceof Inlet
    letBin = letB.bolt.lets[letB.name] instanceof Inlet

    if letAin and letBin
        throw new TypeError "connection spec for two inlets"

    if !letAin and !letBin
        throw new TypeError "connection spec fo two outlets"

    if !letAin
        [letB, letA] = [letA, letB]

    return [letA.bolt.lets[letA.name], letB.bolt.lets[letB.name]]

#-------------------------------------------------------------------------------
class Inlet

    #---------------------------------------------------------------------------
    constructor: (@bolt, @name, @reader) ->

#-------------------------------------------------------------------------------
class Outlet

    #---------------------------------------------------------------------------
    constructor: (@bolt, @name, @descr) ->
        @inlets = []

    #---------------------------------------------------------------------------
    emit: (data) ->
        for inlet in @inlets
            bolt = @bolt
            name = @name

            Bolt.nextTick -> emit bolt, name, inlet, data

        return @

    #---------------------------------------------------------------------------
    addInlet: (inlet) ->
        @inlets.push inlet

    #---------------------------------------------------------------------------
    removeInlet: (inlet) ->
        inlets = []
        for inletTest in @inlets
            if inletTest isnt inlet
                inlets.push inlet

        @inlets = inlets

#-------------------------------------------------------------------------------
emit = (emittingBolt, outletName, inlet, data) ->

    errlet = inlet.bolt.lets["error"]

    if !(errlet instanceof Inlet)

        inlet.reader.call(inlet.bolt, data)

    else


        try
            inlet.reader.call(inlet.bolt, data)
        catch err
            packet =
                outletBolt:  emittingBolt
                outletName:  outletName
                inletBolt:   inlet.bolt
                inletName:   inlet.name
                data:        data
                error:       err

            inlet.bolt.lets["error"].reader.call inlet.bolt, packet

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