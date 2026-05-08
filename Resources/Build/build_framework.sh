#!/bin/bash

# Creating a multiplatform binary framework bundle
# https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle


# Exit on any error
set -e

cd Build

# Add these flags to the following scripts below for the cmake command and execute the scripts:
# -D"INTERPROCEDURAL_OPTIMIZATION=OFF" -D"GENERATE_DEBUG_SYMBOLS=OFF"
# Otherwise the framework creation will fail at the last step
bash cmake_xcode_macos.sh
bash cmake_xcode_ios.sh

cd XCode_MacOS
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk macosx26.4 MACOSX_DEPLOYMENT_TARGET=10.13
cd ..

cd XCode_iOS
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk iphoneos26.4 IPHONEOS_DEPLOYMENT_TARGET=12.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk iphonesimulator26.4 IPHONEOS_DEPLOYMENT_TARGET=12.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk appletvos26.4 TVOS_DEPLOYMENT_TARGET=12.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk appletvsimulator26.4 TVOS_DEPLOYMENT_TARGET=12.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk xros26.4 XROS_DEPLOYMENT_TARGET=1.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk xrsimulator26.4 XROS_DEPLOYMENT_TARGET=1.0
cd ..

cd ..
bash copy_headers.sh Jolt Headers/Jolt

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