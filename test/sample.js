// Licensed under the Tumbolia Public License. See footer for details.

    var dustup = require("../lib/dustup")
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
      a: "testing " + __filename
    })

//------------------------------------------------------------------------------
// Copyright (c) 2013 Patrick Muelle
//
// Tumbolia Public Licens
//
// Copying and distribution of this file, with or without modification, ar
// permitted in any medium without royalty provided the copyright notice an
// this notice are preserved
//
// TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATIO
//
//   0. opan saurce LO
//------------------------------------------------------------------------------
