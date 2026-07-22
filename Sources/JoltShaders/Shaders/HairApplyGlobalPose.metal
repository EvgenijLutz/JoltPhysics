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

struct JPH_HairGlobalPoseTransform
{
    packed_float3 mPosition;
    packed_float4 mRotation;
};

struct type_StructuredBuffer_JPH_HairGlobalPoseTransform
{
    JPH_HairGlobalPoseTransform _m0[1];
};

struct JPH_HairPosition
{
    packed_float3 mPosition;
    packed_float4 mRotation;
};

struct type_RWStructuredBuffer_JPH_HairPosition
{
    JPH_HairPosition _m0[1];
};

kernel void HairApplyGlobalPose(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_uint& gVerticesFixed [[buffer(1)]], device type_StructuredBuffer_uint& gStrandFractions [[buffer(2)]], device type_StructuredBuffer_v3float& gInitialPositions [[buffer(3)]], device type_StructuredBuffer_uint& gInitialBishops [[buffer(4)]], device type_StructuredBuffer_uint& gStrandMaterialIndex [[buffer(5)]], device type_StructuredBuffer_JPH_HairMaterial& gMaterials [[buffer(6)]], device type_StructuredBuffer_JPH_HairGlobalPoseTransform& gGlobalPoseTransforms [[buffer(7)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(8)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        uint _78 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_78 >= gContext.cNumVertices)
        {
            break;
        }
        if ((gVerticesFixed._m0[_78 >> 5u] & (1u << (_78 & 31u))) != 0u)
        {
            break;
        }
        uint _93 = _78 % gContext.cNumStrands;
        uint _101 = (gStrandMaterialIndex._m0[_93 >> 2u] >> (((_93 & 3u) << 3u) & 31u)) & 255u;
        float _115 = float((gStrandFractions._m0[_78 >> 2u] >> (((_78 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125;
        float3 _134 = float3(float(int(gInitialBishops._m0[_78] & 511u) - 255), float(int((gInitialBishops._m0[_78] >> 9u) & 511u) - 255), float((gInitialBishops._m0[_78] >> 18u) & 511u) - 255.0) * 0.0027729677967727184295654296875;
        float4 _142 = float4(_134, sqrt(precise::max(1.0 - dot(_134, _134), 0.0)));
        float4 _148;
        if ((gInitialBishops._m0[_78] & 2147483648u) != 0u)
        {
            _148 = -_142;
        }
        else
        {
            _148 = _142;
        }
        uint _150 = (gInitialBishops._m0[_78] >> 29u) & 3u;
        float4 _168;
        if (_150 == 0u)
        {
            _168 = _148.wxyz;
        }
        else
        {
            float4 _167;
            if (_150 == 1u)
            {
                _167 = _148.xwyz;
            }
            else
            {
                float4 _166;
                if (_150 == 2u)
                {
                    _166 = _148.xywz;
                }
                else
                {
                    _166 = _148;
                }
                _167 = _166;
            }
            _168 = _167;
        }
        float _180 = precise::min(gMaterials._m0[_101].mSkinGlobalPose.w, precise::max(gMaterials._m0[_101].mSkinGlobalPose.z, gMaterials._m0[_101].mSkinGlobalPose.y + (_115 * gMaterials._m0[_101].mSkinGlobalPose.x)));
        float3 _186 = (float3(gInitialPositions._m0[_78][1], gInitialPositions._m0[_78][2], gInitialPositions._m0[_78][0]) * float3(gGlobalPoseTransforms._m0[_93].mRotation[0], gGlobalPoseTransforms._m0[_93].mRotation[1], gGlobalPoseTransforms._m0[_93].mRotation[2])) - (float3(gGlobalPoseTransforms._m0[_93].mRotation[1], gGlobalPoseTransforms._m0[_93].mRotation[2], gGlobalPoseTransforms._m0[_93].mRotation[0]) * float3(gInitialPositions._m0[_78]));
        float3 _187 = _186.yzx;
        float3 _195 = (_187 * gGlobalPoseTransforms._m0[_93].mRotation[3]) + ((_186.zxy * float3(gGlobalPoseTransforms._m0[_93].mRotation[0], gGlobalPoseTransforms._m0[_93].mRotation[1], gGlobalPoseTransforms._m0[_93].mRotation[2])) - (float3(gGlobalPoseTransforms._m0[_93].mRotation[1], gGlobalPoseTransforms._m0[_93].mRotation[2], gGlobalPoseTransforms._m0[_93].mRotation[0]) * _187)).yzx;
        float _248 = precise::min(gMaterials._m0[_101].mGlobalPose.w, precise::max(gMaterials._m0[_101].mGlobalPose.z, gMaterials._m0[_101].mGlobalPose.y + (_115 * gMaterials._m0[_101].mGlobalPose.x)));
        gPositions._m0[_78] = JPH_HairPosition{ (float3(gInitialPositions._m0[_78]) + (((float3(gGlobalPoseTransforms._m0[_93].mPosition) + (float3(gInitialPositions._m0[_78]) + (_195 + _195))) - float3(gInitialPositions._m0[_78])) * _180)) * _248, fast::normalize((_168 + ((float4((((gGlobalPoseTransforms._m0[_93].mRotation[3] * _168.x) + (gGlobalPoseTransforms._m0[_93].mRotation[0] * _168.w)) + (gGlobalPoseTransforms._m0[_93].mRotation[1] * _168.z)) - (gGlobalPoseTransforms._m0[_93].mRotation[2] * _168.y), (((gGlobalPoseTransforms._m0[_93].mRotation[3] * _168.y) - (gGlobalPoseTransforms._m0[_93].mRotation[0] * _168.z)) + (gGlobalPoseTransforms._m0[_93].mRotation[1] * _168.w)) + (gGlobalPoseTransforms._m0[_93].mRotation[2] * _168.x), (((gGlobalPoseTransforms._m0[_93].mRotation[3] * _168.z) + (gGlobalPoseTransforms._m0[_93].mRotation[0] * _168.y)) - (gGlobalPoseTransforms._m0[_93].mRotation[1] * _168.x)) + (gGlobalPoseTransforms._m0[_93].mRotation[2] * _168.w), (((gGlobalPoseTransforms._m0[_93].mRotation[3] * _168.w) - (gGlobalPoseTransforms._m0[_93].mRotation[0] * _168.x)) - (gGlobalPoseTransforms._m0[_93].mRotation[1] * _168.y)) - (gGlobalPoseTransforms._m0[_93].mRotation[2] * _168.z)) - _168) * _180)) * _248) };
        break;
    } while(false);
}

