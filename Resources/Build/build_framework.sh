#!/bin/bash

# Creating a multiplatform binary framework bundle
# https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle


# Exit on any error
set -e


# Copy headers from the Jolt directory into the Headers directory:
# bash copy_headers.sh Jolt Headers/Jolt
# Copy the module.modulemap into the Headers/Jolt-Module to create a headers folder for the framework

# Add these flags to the "cmake_xcode_macos.sh" and the "cmake_xcode_ios.sh" scripts in the Build folder:
# -D"INTERPROCEDURAL_OPTIMIZATION=OFF" -D"GENERATE_DEBUG_SYMBOLS=OFF"

cd Build

# Generate Xcode projects for macOS and iOS, iOS project will be also used for tvOS and visionOS
bash cmake_xcode_macos.sh
bash cmake_xcode_ios.sh

cd XCode_MacOS
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk macosx26.0

cd ../XCode_iOS
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk iphoneos26.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk iphonesimulator26.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk appletvos26.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk appletvsimulator26.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk xros26.0
xcodebuild -project JoltPhysics.xcodeproj -target Jolt -configuration Distribution -sdk xrsimulator26.0
cd ../..


# Generate a framework
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
codesign --timestamp -s "YOUR_SIGNING_KEY" xcframework/Jolt.xcframework

echo
echo "✅ Framework generated successfully!"
