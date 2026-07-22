#!/bin/bash

# bash build_framework.sh

# Distribute a Metal renderer in a Swift package
# https://developer.apple.com/documentation/technotes/tn3133-packaging-a-renderer

# Creating a multiplatform binary framework bundle
# https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle


# Exit on any error
set -e

cd JoltPhysics-5.6.0

cd Build


# Build for macOS
cmake -S . -B XCode_MacOS -GXcode -D"CMAKE_OSX_ARCHITECTURES=x86_64;arm64" -DINTERPROCEDURAL_OPTIMIZATION=OFF -DGENERATE_DEBUG_SYMBOLS=OFF -DJPH_USE_CPU_COMPUTE=OFF -DJPH_USE_DX12=NO -DJPH_USE_VK=NO -DJPH_USE_MTL=ON
cd XCode_MacOS
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk macosx26.5 MACOSX_DEPLOYMENT_TARGET=26.0
cd ..


# Build for iOS
cmake -S . -B XCode_iOS -GXcode -DTARGET_HELLO_WORLD=OFF -DTARGET_PERFORMANCE_TEST=OFF -DCMAKE_SYSTEM_NAME=iOS -DINTERPROCEDURAL_OPTIMIZATION=OFF -DGENERATE_DEBUG_SYMBOLS=OFF -DJPH_USE_CPU_COMPUTE=OFF -DJPH_USE_DX12=NO -DJPH_USE_VK=NO -DJPH_USE_MTL=ON
cd XCode_iOS
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk iphoneos26.5 IPHONEOS_DEPLOYMENT_TARGET=26.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk iphonesimulator26.5 IPHONEOS_DEPLOYMENT_TARGET=26.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk appletvos26.5 TVOS_DEPLOYMENT_TARGET=26.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk appletvsimulator26.5 TVOS_DEPLOYMENT_TARGET=26.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk xros26.5 XROS_DEPLOYMENT_TARGET=26.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk xrsimulator26.5 XROS_DEPLOYMENT_TARGET=26.0
cd ..


# Copy headers
cd ..
bash ../copy_headers.sh Jolt Headers/Jolt


# Copy generated Metal shader sources into the Shaders folder
rm -rf Shaders
mkdir -p Shaders
find Build/XCode_MacOS -name \*.metal -exec cp {} Shaders \;
echo "✅ Metal shader files copied successfully!"


# Bundle compiled static libraries into an xcframework
rm -rf xcframework/Jolt.xcframework
xcodebuild -create-xcframework \
    -output xcframework/Jolt.xcframework \
    -library Build/XCode_MacOS/Distribution/libJolt.a                  -headers Headers \
    -library Build/XCode_iOS/Distribution-iphoneos/libJolt.a           -headers Headers \
    -library Build/XCode_iOS/Distribution-iphonesimulator/libJolt.a    -headers Headers \
    -library Build/XCode_iOS/Distribution-appletvos/libJolt.a          -headers Headers \
    -library Build/XCode_iOS/Distribution-appletvsimulator/libJolt.a   -headers Headers \
    -library Build/XCode_iOS/Distribution-xros/libJolt.a               -headers Headers \
    -library Build/XCode_iOS/Distribution-xrsimulator/libJolt.a        -headers Headers \

# And sign the framework
codesign --timestamp -s 070BA25D98F2A17A61E3E27E31BE64C06F901016 xcframework/Jolt.xcframework
echo "✅ XCFramework created successfully!"
