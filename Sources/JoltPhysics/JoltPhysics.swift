//
//  JoltPhysics.swift
//  JoltPhysics
//
//  Created by Evgenij Lutz on 27.07.26.
//

@_exported import JoltPhysicsExtensions

func joltTest() {
    // Register the default allocator
    JPH.RegisterDefaultAllocator()
    
    // Create compute system
    let result = JPH.CreateComputeSystem()
    if result.HasError() {
        return
    }
    
    _ = result.__GetUnsafe()
}
