#!/bin/bash

set -e

ROOT_DOLPHIN_DIR="$PROJECT_DIR/../../.."
CMAKE_BUILD_DIR="$ROOT_DOLPHIN_DIR/build-$PLATFORM_NAME-$DOLPHIN_BUILD_TYPE"
ADDITIONAL_CMAKE_SETTINGS=

case $PLATFORM_NAME in
    iphoneos)
        PLATFORM=OS64
        PLATFORM_DEPLOYMENT_TARGET="12.0"
        ;;
    iphonesimulator)
        PLATFORM=SIMULATOR64
        PLATFORM_DEPLOYMENT_TARGET="12.0"
        ;;
    appletvos)
        PLATFORM=TVOS
        PLATFORM_DEPLOYMENT_TARGET="14.0"
        ;;
    appletvsimulator)
        PLATFORM=SIMULATOR_TVOS
        PLATFORM_DEPLOYMENT_TARGET="14.0"
        ;;
    *)
        PLATFORM=UNKNOWN
        ;;
esac

if [ $PLATFORM == "UNKNOWN" ]; then
    echo "Unknown platform \"$PLATFORM_NAME\""
    exit 1
fi

if [ $BUILD_FOR_JAILBROKEN_DEVICE == "YES" ]; then
  CMAKE_BUILD_DIR="$CMAKE_BUILD_DIR-jb"
  ADDITIONAL_CMAKE_SETTINGS="-DIOS_JAILBROKEN=1"
fi

if [ ! -d "$CMAKE_BUILD_DIR" ]; then
    mkdir "$CMAKE_BUILD_DIR"
    cd "$CMAKE_BUILD_DIR"
    
    cmake "$ROOT_DOLPHIN_DIR" -GNinja -DCMAKE_TOOLCHAIN_FILE="$ROOT_DOLPHIN_DIR/Source/iOS/ios.toolchain.cmake" -DPLATFORM=$PLATFORM -DDEPLOYMENT_TARGET=$PLATFORM_DEPLOYMENT_TARGET -DCMAKE_BUILD_TYPE=$DOLPHIN_BUILD_TYPE -DENABLE_ANALYTICS=NO $ADDITIONAL_CMAKE_SETTINGS
fi

cd $CMAKE_BUILD_DIR

ninja

if [ ! -d "$CMAKE_BUILD_DIR/libs" ]; then
    mkdir "$CMAKE_BUILD_DIR/libs"
    mkdir "$CMAKE_BUILD_DIR/libs/Dolphin"
    mkdir "$CMAKE_BUILD_DIR/libs/Externals"
fi

rm -f "$CMAKE_BUILD_DIR/libs/Dolphin/"*.a
rm -f "$CMAKE_BUILD_DIR/libs/Externals/"*.a

find Source/ -name '*.a' -exec ln '{}' "$CMAKE_BUILD_DIR/libs/Dolphin/" ';'

find Externals/ -name '*.a' -exec ln '{}' "$CMAKE_BUILD_DIR/libs/Externals/" ';'
