#!/bin/bash
DIR="$(cd "$(dirname "$0")"; pwd)"
export DYLD_INSERT_LIBRARIES="$DIR/hook.dylib"
exec "$DIR/Postico.o" > /dev/null 2>&1