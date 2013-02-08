# Licensed under the Tumbolia Public License. See footer for details.

    dustup = require "../lib/dustup"
    Bolt   = dustup.Bolt

    boltA = new Bolt
        outlets:
            a: "outlet a"

    boltB = new Bolt
        inlets:
            b: (data) ->
                console.log data

    Bolt.connect a: boltA, b: boltB

    boltA.emit a: "testing: #{__filename}"

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