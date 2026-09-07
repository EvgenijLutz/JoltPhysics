//
//  JoltPhysicsExtensions.cpp
//  JoltPhysics
//
//  Created by Evgenij Lutz on 27.07.26.
//

#include <JoltPhysicsExtensions/JoltPhysicsExtensions.hpp>




RefTest::RefTest() {
    counter = 1;
}

RefTest::~RefTest() {
    //
}

void RefTest::Retain() {
    counter++;
}

void RefTest::Release() {
    counter--;
    if (counter == 0) {
        delete this;
    }
}


void RefTestRetain(RefTest* value) {
    value->Retain();
}
void RefTestRelease(RefTest* value) {
    value->Release();
}




void ComputeSystemRetain(JPH::ComputeSystem* computeSystem) {
    computeSystem->AddRef();
}

void ComputeSystemRelease(JPH::ComputeSystem* computeSystem) {
    computeSystem->Release();
}
