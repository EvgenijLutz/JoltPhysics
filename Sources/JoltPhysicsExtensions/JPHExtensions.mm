//
//  JPHExtensions.mm
//  JoltPhysics
//
//  Created by Evgenij Lutz on 28.07.26.
//

#include <JoltShaders/JoltShaders.h>
#include <JoltPhysicsExtensions/JPHExtensions.hpp>


namespace JPHExtensions {

std::string JPHStringToCxxString(const JPH::String& string) {
    return string.data();
}


void initializeComputeSystem(JPH::ComputeSystem& computeSystem) {
    // Provide Metal library loader
    computeSystem.mShaderLoader = [](const char*, JPH::Array<JPH::uint8>& outData, JPH::String& outError) -> bool {
        // The GetJoltShadersBundle function is a helper function that returns a bundle containing the compiled Jolt compute shaders
        auto bundle = GetJoltShadersBundle();
        NSURL* url = [bundle URLForResource:@"default" withExtension:@"metallib"];
        
        // Make sure that the library was indeed found
        if (url == nil) {
            outError = "default.metallib was not found in the SwiftPM bundle";
            return false;
        }
        
        // Load the library file contents
        NSError* error = nil;
        NSData* data = [NSData dataWithContentsOfURL:url options:0 error:&error];
        if (data == nil) {
            const char *description = error.localizedDescription.UTF8String;
            outError = description != nullptr ? description : "Failed to read default.metallib";
            return false;
        }
        
        // And write it to the output data
        outData.resize(data.length);
        std::memcpy(outData.data(), data.bytes, data.length);

        return true;
    };
}

}
