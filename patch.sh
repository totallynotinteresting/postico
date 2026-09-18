#!/bin/bash
set -e

read -p "Enter the path to the app (default: /Applications/Postico\ 2.app): " APP_PATH
APP_PATH=${APP_PATH:-/Applications/Postico\ 2.app}

MACOS_PATH="$APP_PATH/Contents/MacOS"

REPO_URL="https://github.com/totallynotinteresting/postico.git"
RAW_URL="https://raw.githubusercontent.com/totallynotinteresting/postico/main"
RELEASE_URL="https://github.com/totallynotinteresting/postico/releases/latest/download/hook.dylib"

if [ ! -d "$MACOS_PATH" ]; then
    echo "Postico.app was not found at $MACOS_PATH"
    echo "please make sure that Postico 2.app is in /Applications/"
    exit 1
fi

cd "$MACOS_PATH" || exit 1
echo "went into $(pwd)"

if git clone "$REPO_URL" postico_patch; then
    echo "cloned repo to $(pwd)"
    cd postico_patch || exit 1
    echo "building hook.dylib because this contains the logic"
    if clang -dynamiclib -framework Foundation -framework AppKit -o hook.dylib hook.m; then
        echo "Build successful."
    else
        echo "either somethings gone wrong or you dont have clang installed, so we're gonna download it from the gh directly"
        curl -L -o hook.dylib "$RELEASE_URL"
    fi
else
    mkdir -p postico_patch
    cd postico_patch || exit 1    
    curl -L -o postico.sh "$RAW_URL/postico.sh"
    curl -L -o hook.dylib "$RELEASE_URL"
fi

# ok well if it doesnt exist, you've clearly done something wrong
if [ ! -f hook.dylib ]; then
    echo "how the hell is hook.dylib not there?"
    cd ..
    rm -rf postico_patch
    exit 1
fi

echo "signing it because macos is specal like that"
codesign -f -s - hook.dylib

echo "blah blah moving it to where it belongs"
mv hook.dylib ..
mv ../postico.sh ../Postico
echo "gotta resign postico as well because something about macos doing hardened runtime"
codesign --remove-signature ../Postico
codesign --force --deep --sign - ../Postico
mv ../Postico ../Postico.o
mv ./postico.sh ../Postico
chmod +x ../Postico

cd ..
rm -rf postico_patch

echo "uh sure try it out"
