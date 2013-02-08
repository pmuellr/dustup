# Licensed under the Tumbolia Public License. See footer for details.

.PHONY: lib test

default: help

#-------------------------------------------------------------------------------
clean:  make-writable
	@echo "cleaning up"
	@rm -rf lib

#-------------------------------------------------------------------------------
watch:
	wr "make build" src-lib

#-------------------------------------------------------------------------------
build: make-writable lib make-readonly

#-------------------------------------------------------------------------------
make-writable:
	@echo making generated files writable
	@-chmod -R +w lib/*

#-------------------------------------------------------------------------------
make-readonly:
	@echo making generated files read-only
	@chmod -R -w lib/*

#-------------------------------------------------------------------------------
lib:
	@echo "generating lib"

	@$(CSC) --output lib src-lib/*.coffee

#-------------------------------------------------------------------------------
test:
	@./node_modules/.bin/mocha \
		--compilers coffee:coffee-script \
		--ui tdd

#-------------------------------------------------------------------------------
help:
	@echo "available targets:"
	@echo "   clean - erase built files"
	@echo "   build - run the build"
	@echo "   watch - watch for source changes, then run the build"
	@echo "   test  - run the tests"
	@echo "   help  - print this help"

#-------------------------------------------------------------------------------

CSC = ./node_modules/.bin/coffee --bare --compile

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