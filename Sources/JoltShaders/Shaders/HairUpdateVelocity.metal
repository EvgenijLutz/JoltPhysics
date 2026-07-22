#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct type_gContext
{
    uint cNumStrands;
    uint cNumVertices;
    uint cNumGridPoints;
    uint cNumRenderVertices;
    packed_uint3 cGridSizeMin2;
    float cTwoDivDeltaTime;
    packed_float3 cGridSizeMin1;
    float cDeltaTime;
    packed_float3 cGridOffset;
    float cHalfDeltaTime;
    packed_float3 cGridScale;
    float cInvDeltaTimeSq;
    packed_float3 cSubStepGravity;
    uint cNumSkinVertices;
    packed_uint3 cGridStride;
    uint cNumSkinWeightsPerVertex;
    float4 cDeltaTransform[4];
    float4 cScalpToHead[4];
    float4 cDeltaTransformQuat;
};

struct type_gIterationContext
{
    float cAccumulatedDeltaTime;
    float cIterationFraction;
};

struct type_StructuredBuffer_uint
{
    uint _m0[1];
};

struct type_StructuredBuffer_v3float
{
    packed_float3 _m0[1];
};

struct JPH_HairMaterial
{
    float4 mWorldTransformInfluence;
    float4 mGlobalPose;
    float4 mSkinGlobalPose;
    float4 mGravityFactor;
    float4 mHairRadius;
    float4 mBendComplianceMultiplier;
    float4 mGridVelocityFactor;
    uint mEnableCollision;
    uint mEnableLRA;
    uint mEnableGrid;
    float mFriction;
    float mExpLinearDampingDeltaTime;
    float mExpAngularDampingDeltaTime;
    float mBendComplianceInvDeltaTimeSq;
    float mStretchComplianceInvDeltaTimeSq;
    float mGridDensityForceFactor;
    float mInertiaMultiplier;
    float mMaxLinearVelocitySq;
    float mMaxAngularVelocitySq;
};

struct type_StructuredBuffer_JPH_HairMaterial
{
    JPH_HairMaterial _m0[1];
};

struct JPH_HairPosition
{
    packed_float3 mPosition;
    packed_float4 mRotation;
};

struct type_StructuredBuffer_JPH_HairPosition
{
    JPH_HairPosition _m0[1];
};

struct JPH_HairGlobalPoseTransform
{
    packed_float3 mPosition;
    packed_float4 mRotation;
};

struct type_StructuredBuffer_JPH_HairGlobalPoseTransform
{
    JPH_HairGlobalPoseTransform _m0[1];
};

struct JPH_HairCollisionShape
{
    packed_float3 mCenterOfMass;
    packed_float3 mLinearVelocity;
    packed_float3 mAngularVelocity;
};

struct type_StructuredBuffer_JPH_HairCollisionShape
{
    JPH_HairCollisionShape _m0[1];
};

struct JPH_HairCollisionPlane
{
    packed_float4 mPlane;
    uint mShapeIndex;
};

struct type_StructuredBuffer_JPH_HairCollisionPlane
{
    JPH_HairCollisionPlane _m0[1];
};

struct type_RWStructuredBuffer_JPH_HairPosition
{
    JPH_HairPosition _m0[1];
};

struct JPH_HairVelocity
{
    packed_float3 mVelocity;
    packed_float3 mAngularVelocity;
};

struct type_RWStructuredBuffer_JPH_HairVelocity
{
    JPH_HairVelocity _m0[1];
};

constant float _99 = {};

kernel void HairUpdateVelocity(constant type_gContext& gContext [[buffer(0)]], constant type_gIterationContext& gIterationContext [[buffer(1)]], device type_StructuredBuffer_uint& gVerticesFixed [[buffer(2)]], device type_StructuredBuffer_uint& gStrandFractions [[buffer(3)]], device type_StructuredBuffer_v3float& gInitialPositions [[buffer(4)]], device type_StructuredBuffer_uint& gInitialBishops [[buffer(5)]], device type_StructuredBuffer_uint& gStrandMaterialIndex [[buffer(6)]], device type_StructuredBuffer_JPH_HairMaterial& gMaterials [[buffer(7)]], device type_StructuredBuffer_JPH_HairPosition& gPreviousPositions [[buffer(8)]], device type_StructuredBuffer_JPH_HairGlobalPoseTransform& gGlobalPoseTransforms [[buffer(9)]], device type_StructuredBuffer_JPH_HairCollisionShape& gCollisionShapes [[buffer(10)]], device type_StructuredBuffer_JPH_HairCollisionPlane& gCollisionPlanes [[buffer(11)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(12)]], device type_RWStructuredBuffer_JPH_HairVelocity& gVelocities [[buffer(13)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        uint _107 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_107 >= gContext.cNumVertices)
        {
            break;
        }
        if ((gVerticesFixed._m0[_107 >> 5u] & (1u << (_107 & 31u))) != 0u)
        {
            break;
        }
        uint _122 = _107 % gContext.cNumStrands;
        uint _130 = (gStrandMaterialIndex._m0[_122 >> 2u] >> (((_122 & 3u) << 3u) & 31u)) & 255u;
        float _154 = float((gStrandFractions._m0[_107 >> 2u] >> (((_107 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125;
        float3 _173 = float3(float(int(gInitialBishops._m0[_107] & 511u) - 255), float(int((gInitialBishops._m0[_107] >> 9u) & 511u) - 255), float((gInitialBishops._m0[_107] >> 18u) & 511u) - 255.0) * 0.0027729677967727184295654296875;
        float4 _181 = float4(_173, sqrt(precise::max(1.0 - dot(_173, _173), 0.0)));
        float4 _187;
        if ((gInitialBishops._m0[_107] & 2147483648u) != 0u)
        {
            _187 = -_181;
        }
        else
        {
            _187 = _181;
        }
        uint _189 = (gInitialBishops._m0[_107] >> 29u) & 3u;
        float4 _207;
        if (_189 == 0u)
        {
            _207 = _187.wxyz;
        }
        else
        {
            float4 _206;
            if (_189 == 1u)
            {
                _206 = _187.xwyz;
            }
            else
            {
                float4 _205;
                if (_189 == 2u)
                {
                    _205 = _187.xywz;
                }
                else
                {
                    _205 = _187;
                }
                _206 = _205;
            }
            _207 = _206;
        }
        float _228 = precise::min(gMaterials._m0[_130].mSkinGlobalPose.w, precise::max(gMaterials._m0[_130].mSkinGlobalPose.z, gMaterials._m0[_130].mSkinGlobalPose.y + (_154 * gMaterials._m0[_130].mSkinGlobalPose.x)));
        float3 _234 = (float3(gInitialPositions._m0[_107][1], gInitialPositions._m0[_107][2], gInitialPositions._m0[_107][0]) * float3(gGlobalPoseTransforms._m0[_122].mRotation[0], gGlobalPoseTransforms._m0[_122].mRotation[1], gGlobalPoseTransforms._m0[_122].mRotation[2])) - (float3(gGlobalPoseTransforms._m0[_122].mRotation[1], gGlobalPoseTransforms._m0[_122].mRotation[2], gGlobalPoseTransforms._m0[_122].mRotation[0]) * float3(gInitialPositions._m0[_107]));
        float3 _235 = _234.yzx;
        float3 _243 = (_235 * gGlobalPoseTransforms._m0[_122].mRotation[3]) + ((_234.zxy * float3(gGlobalPoseTransforms._m0[_122].mRotation[0], gGlobalPoseTransforms._m0[_122].mRotation[1], gGlobalPoseTransforms._m0[_122].mRotation[2])) - (float3(gGlobalPoseTransforms._m0[_122].mRotation[1], gGlobalPoseTransforms._m0[_122].mRotation[2], gGlobalPoseTransforms._m0[_122].mRotation[0]) * _235)).yzx;
        float _296 = precise::min(gMaterials._m0[_130].mGlobalPose.w, precise::max(gMaterials._m0[_130].mGlobalPose.z, gMaterials._m0[_130].mGlobalPose.y + (_154 * gMaterials._m0[_130].mGlobalPose.x)));
        float3 _299 = float3(gPositions._m0[_107].mPosition) + (((float3(gInitialPositions._m0[_107]) + (((float3(gGlobalPoseTransforms._m0[_122].mPosition) + (float3(gInitialPositions._m0[_107]) + (_243 + _243))) - float3(gInitialPositions._m0[_107])) * _228)) - float3(gPositions._m0[_107].mPosition)) * _296);
        float4 _303 = fast::normalize(float4(gPositions._m0[_107].mRotation) + (((_207 + ((float4((((gGlobalPoseTransforms._m0[_122].mRotation[3] * _207.x) + (gGlobalPoseTransforms._m0[_122].mRotation[0] * _207.w)) + (gGlobalPoseTransforms._m0[_122].mRotation[1] * _207.z)) - (gGlobalPoseTransforms._m0[_122].mRotation[2] * _207.y), (((gGlobalPoseTransforms._m0[_122].mRotation[3] * _207.y) - (gGlobalPoseTransforms._m0[_122].mRotation[0] * _207.z)) + (gGlobalPoseTransforms._m0[_122].mRotation[1] * _207.w)) + (gGlobalPoseTransforms._m0[_122].mRotation[2] * _207.x), (((gGlobalPoseTransforms._m0[_122].mRotation[3] * _207.z) + (gGlobalPoseTransforms._m0[_122].mRotation[0] * _207.y)) - (gGlobalPoseTransforms._m0[_122].mRotation[1] * _207.x)) + (gGlobalPoseTransforms._m0[_122].mRotation[2] * _207.w), (((gGlobalPoseTransforms._m0[_122].mRotation[3] * _207.w) - (gGlobalPoseTransforms._m0[_122].mRotation[0] * _207.x)) - (gGlobalPoseTransforms._m0[_122].mRotation[1] * _207.y)) - (gGlobalPoseTransforms._m0[_122].mRotation[2] * _207.z)) - _207) * _228)) - float4(gPositions._m0[_107].mRotation)) * _296));
        float3 _308 = (_299 - float3(gPreviousPositions._m0[_107].mPosition)) / float3(gContext.cDeltaTime);
        float _310 = -gPreviousPositions._m0[_107].mRotation[0];
        float _312 = -gPreviousPositions._m0[_107].mRotation[1];
        float _314 = -gPreviousPositions._m0[_107].mRotation[2];
        float _316 = _303.w;
        float _318 = _303.x;
        float _321 = _303.y;
        float _324 = _303.z;
        float3 _345 = float4((((_316 * _310) + (_318 * gPreviousPositions._m0[_107].mRotation[3])) + (_321 * _314)) - (_324 * _312), (((_316 * _312) - (_318 * _314)) + (_321 * gPreviousPositions._m0[_107].mRotation[3])) + (_324 * _310), (((_316 * _314) + (_318 * _312)) - (_321 * _310)) + (_324 * gPreviousPositions._m0[_107].mRotation[3]), _99).xyz * gContext.cTwoDivDeltaTime;
        float3 _409;
        float3 _410;
        if (gMaterials._m0[_130].mEnableCollision != 0u)
        {
            float _356 = dot(_299, float3(gCollisionPlanes._m0[_107].mPlane[0], gCollisionPlanes._m0[_107].mPlane[1], gCollisionPlanes._m0[_107].mPlane[2])) + gCollisionPlanes._m0[_107].mPlane[3];
            float3 _367 = float3(gCollisionShapes._m0[gCollisionPlanes._m0[_107].mShapeIndex].mLinearVelocity) + cross(float3(gCollisionShapes._m0[gCollisionPlanes._m0[_107].mShapeIndex].mAngularVelocity), (_299 - (float3(gCollisionPlanes._m0[_107].mPlane[0], gCollisionPlanes._m0[_107].mPlane[1], gCollisionPlanes._m0[_107].mPlane[2]) * _356)) - float3(gCollisionShapes._m0[gCollisionPlanes._m0[_107].mShapeIndex].mCenterOfMass));
            float _381 = ((dot(_367, float3(gCollisionPlanes._m0[_107].mPlane[0], gCollisionPlanes._m0[_107].mPlane[1], gCollisionPlanes._m0[_107].mPlane[2])) * gIterationContext.cAccumulatedDeltaTime) - _356) + precise::min(gMaterials._m0[_130].mHairRadius.w, precise::max(gMaterials._m0[_130].mHairRadius.z, gMaterials._m0[_130].mHairRadius.y + (_154 * gMaterials._m0[_130].mHairRadius.x)));
            float3 _407;
            float3 _408;
            if (_381 > 0.0)
            {
                float3 _387 = _308 - _367;
                float _388 = dot(float3(gCollisionPlanes._m0[_107].mPlane[0], gCollisionPlanes._m0[_107].mPlane[1], gCollisionPlanes._m0[_107].mPlane[2]), _387);
                float3 _406;
                if (_388 < 0.0)
                {
                    float3 _392 = float3(gCollisionPlanes._m0[_107].mPlane[0], gCollisionPlanes._m0[_107].mPlane[1], gCollisionPlanes._m0[_107].mPlane[2]) * _388;
                    float3 _393 = _387 - _392;
                    float _394 = length(_393);
                    float3 _404;
                    if (_394 > 0.0)
                    {
                        _404 = _308 - (_393 * precise::min((gMaterials._m0[_130].mFriction * _381) / (_394 * gContext.cDeltaTime), 1.0));
                    }
                    else
                    {
                        _404 = _308;
                    }
                    _406 = _404 - _392;
                }
                else
                {
                    _406 = _308;
                }
                _407 = _299 + (float3(gCollisionPlanes._m0[_107].mPlane[0], gCollisionPlanes._m0[_107].mPlane[1], gCollisionPlanes._m0[_107].mPlane[2]) * _381);
                _408 = _406;
            }
            else
            {
                _407 = _299;
                _408 = _308;
            }
            _409 = _407;
            _410 = _408;
        }
        else
        {
            _409 = _299;
            _410 = _308;
        }
        float _411 = dot(_410, _410);
        float3 _418;
        if (_411 > gMaterials._m0[_130].mMaxLinearVelocitySq)
        {
            _418 = _410 * sqrt(gMaterials._m0[_130].mMaxLinearVelocitySq / _411);
        }
        else
        {
            _418 = _410;
        }
        float _419 = dot(_345, _345);
        float3 _426;
        if (_419 > gMaterials._m0[_130].mMaxAngularVelocitySq)
        {
            _426 = _345 * sqrt(gMaterials._m0[_130].mMaxAngularVelocitySq / _419);
        }
        else
        {
            _426 = _345;
        }
        gPositions._m0[_107] = JPH_HairPosition{ _409, _303 };
        gVelocities._m0[_107] = JPH_HairVelocity{ _418, _426 };
        break;
    } while(false);
}

