//
//  JPHExtensions.hpp
//  JoltPhysics
//
//  Created by Evgenij Lutz on 28.07.26.
//

#pragma once

#include "ExtHeaderStart.hpp"
#include <Jolt/Jolt.h>
#include <Jolt/Compute/ComputeSystem.h>
#include <Jolt/Core/STLAllocator.h>
#include <string>
#include "ExtHeaderEnd.hpp"


#if defined __cplusplus


class RefTest {
private:
    int counter;
    
    RefTest();
    virtual ~RefTest();
    
public:
    void Retain();
    void Release();
};


void RefTestRetain(RefTest* _Nonnull value);
void RefTestRelease(RefTest* _Nonnull value);


void JoltExt_ComputeSystemRetain(JPH::ComputeSystem* _Nonnull computeSystem);
void JoltExt_ComputeSystemRelease(JPH::ComputeSystem* _Nonnull computeSystem);


namespace JPHExtensions {

std::string JPHStringToCxxString(const JPH::String& string);

void initializeComputeSystem(JPH::ComputeSystem& computeSystem);

}

#endif
