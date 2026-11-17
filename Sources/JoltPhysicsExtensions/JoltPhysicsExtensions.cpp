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


void RefTestRetain(RefTest* _Nonnull value) {
    value->Retain();
}
void RefTestRelease(RefTest* _Nonnull value) {
    value->Release();
}




void JoltExt_ComputeSystemRetain(JPH::ComputeSystem* _Nonnull computeSystem) {
    computeSystem->AddRef();
}

void JoltExt_ComputeSystemRelease(JPH::ComputeSystem* _Nonnull computeSystem) {
    computeSystem->Release();
}
