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


public enum JPHError: Error {
    case other(_ message: String)
}


public extension JPH.ComputeSystem {
    /// Creates a ``JPH.ComputeSystem`` instance and initialises its shader loading function.
    static func create() throws -> JPH.ComputeSystem {
        let result = JPH.CreateComputeSystem()
        if result.HasError() {
            let err = result.__GetErrorUnsafe()
            let stdString = JPHExtensions.JPHStringToCxxString(err.pointee)
            let errorMessage = String(stdString)
            throw JPHError.other(errorMessage)
        }
        
        let computeSystem = result.__GetUnsafe().pointee.pointee
        JPHExtensions.initializeComputeSystem(computeSystem)
        
        return computeSystem
    }
}


extension RefTest {
//    func lala() {
//        let test = RefTest()
//        _ = test
//    }
}
