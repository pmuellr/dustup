dustup - in-process pipelines for JavaScript kinda like Twitter Storm
================================================================================

[Twitter Storm](http://storm-project.net/) is cool, but it would be nice to
have a version just for dealing with in-process stuff in JavaScript, compared
to full-fledged multi-machine distribution.  Other liberties have been taken.


what is
--------------------------------------------------------------------------------

In Storm, you have *spouts* with generate data, and *bolts* which read and/or
write data.  In `dustup`, there are no *spouts*, just Bolts.

The inlets and outlets of a Bolt are named and defined when you create the
bolt.  After creating a bolt, you can connect it's inlets and outlets to other
bolt's outlets and inlets (respectively).

Finally, you start `emit()`ing data from a Bolt's outlet.  And let things happen.
Any inlet connected to an outlet that `emit()`s data will have it's inlet
function invoked.  The bolt's inlet function can then `emit()` an object to it's
own outlets to continue the fun.

Inlet functions are always invoked with `this` set to the inlet's bolt,
and always invoked on *nextTick*, asynchronously.


sample
--------------------------------------------------------------------------------

in CoffeeScript:

    dustup = require "dustup"
    Bolt   = dustup.Bolt

    boltA = new Bolt
        outlets:
            a: "outlet a"

    boltB = new Bolt
        inlets:
            b: (data) ->
                console.log data

    Bolt.connect a: boltA, b: boltB

    boltA.emit a: "it should be working"

in JavaScript:

    var dustup = require("dustup")
    var Bolt   = dustup.Bolt

    var boltA = new Bolt({
      outlets: {
        a: "outlet a"
      }
    })

    var boltB = new Bolt({
      inlets: {
        b: function(data) {
          return console.log(data);
        }
      }
    })

    Bolt.connect({
      a: boltA,
      b: boltB
    })

    boltA.emit({
      a: "it should be working"
    })


api
--------------------------------------------------------------------------------

The `dustup` module exports an object which contains the following properties:

* `Bolt` - the `Bolt` constructor


### `Bolt` constructor ###

`Bolt` is a class which you use to create new bolts with.  It's subclassable
in the usual way (including CoffeeScript), but for many cases you won't need
to subclass it at all.

Create a new bolt by calling the `Bolt` constructor with a *boltSpec*.

A *boltspec* is an object that contains the following properties:

* `name`: the name of the bolt as a string
* `inlets`: an object containing the inlets for the bolt
* `outlets`: an object describing the outlets for the bolt

`inlets` are specified as an object whose properties are the name/value of
the inlet.  The value should be a function which takes one argument - the data
- and does something with it.
Inlet functions are always invoked with `this` set to the inlet's bolt,
and always invoked on *nextTick*, asynchronously.


`outlets` are specified as an object whose properties are the name/value of
the outlet.  The value is currently ignored.


### `Bolt.prototype.emit(outletName, data)` ###

*an instance metod of `Bolt`*

A `Bolt` object only has one method `emit(name, data)`.  This method is used
to emit the specified data on the named outlet.  You may also invoke `emit()`
with an object, in which case the name/value properties of the object will
be used to emit multiple data items across multiple outlets.  Eg,

    emit({a:1, b:2})

is the same as

    emit(a,1)
    emit(b,2)


### `Bolt.connect(connectionSpecs)` ###

*a class method of `Bolt`*

`Bolt.connect` is used to connect an outlet to an inlet.  *connectionSpecs* are
specified as an object whose property name/values should be inlet/outlet names
and bolts.  For instance, in the sample above, the following connection is
made:

    Bolt.connect({
      a: boltA,
      b: boltB
    })

This will connect
the inlet/outlet named `"a"` of bolt `boltA` to the
the inlet/outlet named `"b"` of bolt `boltB`.

A couple of constraints:

* you can only specify two properties
* one of the properties must be an inlet and the other an outlet

### `Bolt.disconnect(connectionSpecs)` ###

*a class method of `Bolt`*

Same as `Bolt.disconnect(connectionSpecs)`, only an existing connection between
an inlet and outlet will be removed.


copyright
--------------------------------------------------------------------------------

Copyright 2013 Patrick Mueller


license
--------------------------------------------------------------------------------

Tumbolia Public License

Copying and distribution of this file, with or without modification, are
permitted in any medium without royalty provided the copyright notice and
this notice are preserved.

    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
      0. opan saurce LOL
