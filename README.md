dustup - pipelines for JavaScript
================================================================================

`dustup` is based on the high level design of
[Twitter Storm](http://storm-project.net/), but for JavaScript, and it's
all in process.  Other liberties have been taken.  The terminology of
*inlets* and *outlets* is from [Pure Data](http://puredata.info/).

what is
--------------------------------------------------------------------------------

In Storm, you have *spouts* with generate data, and *bolts* which read and/or
write data.  In `dustup`, there are no *spouts*, just Bolts.

Bolts have inlets and outlets; data is received from inlets and can be
sent out on outlets.  Inlets and outlets can be connected together.
When a message is sent on an outlet, any inlets which are connected to the
outlet will receive the message.

The inlets and outlets of a Bolt are named and defined when you create the
bolt.

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

### error handling for inlet functions ###

You can arrange to have automatic error handling for inlet functions by creating
an outlet on the inlet's bolt named `error`.  If an exception is caught
while running such an inlet function, an error object will be `emit()`ed on
the `error` outlet.  The object contains the following properties:

* `outletBolt` - the bolt which generated the data the inlet is processing
* `outletName` - the name of the outlet which generated the data
* `inletBolt`  - the bolt which owns the inlet which was passed the data
* `inletName`  - the name of the inet which was passed the data
* `data`       - the data that was passed to the inlet
* `error`      - the exception which occurred

Note that if you do **NOT** have an `error` outlet on such bolts, no
exception handling will take place, so exceptions will generally flow to the
top level and kill your program.

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
