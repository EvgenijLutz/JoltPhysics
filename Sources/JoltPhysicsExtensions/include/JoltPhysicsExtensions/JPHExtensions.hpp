//
//  JPHExtensions.hpp
//  JoltPhysics
//
//  Created by Evgenij Lutz on 28.07.26.
//

#pragma once

#include <JoltPhysicsExtensions/JoltUmbrella.hpp>
#include <string>


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


void RefTestRetain(RefTest* value);
void RefTestRelease(RefTest* value);


void ComputeSystemRetain(JPH::ComputeSystem* computeSystem);
void ComputeSystemRelease(JPH::ComputeSystem* computeSystem);


namespace JPHExtensions {

std::string JPHStringToCxxString(const JPH::String& string);

void initializeComputeSystem(JPH::ComputeSystem& computeSystem);

}

#endif
