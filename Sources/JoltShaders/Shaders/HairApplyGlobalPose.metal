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
        uint _89 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_89 >= gContext.cNumVertices)
        {
            break;
        }
        if ((gVerticesFixed._m0[_89 >> 5u] & (1u << (_89 & 31u))) != 0u)
        {
            break;
        }
        uint _106 = _89 % gContext.cNumStrands;
        uint _114 = (gStrandMaterialIndex._m0[_106 >> 2u] >> (((_106 & 3u) << 3u) & 31u)) & 255u;
        float _129 = float((gStrandFractions._m0[_89 >> 2u] >> (((_89 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125;
        float3 _148 = float3(float(int(gInitialBishops._m0[_89] & 511u) - 255), float(int((gInitialBishops._m0[_89] >> 9u) & 511u) - 255), float((gInitialBishops._m0[_89] >> 18u) & 511u) - 255.0) * 0.0027729677967727184295654296875;
        float4 _156 = float4(_148, sqrt(precise::max(1.0 - dot(_148, _148), 0.0)));
        float4 _162;
        if ((gInitialBishops._m0[_89] & 2147483648u) != 0u)
        {
            _162 = -_156;
        }
        else
        {
            _162 = _156;
        }
        uint _164 = (gInitialBishops._m0[_89] >> 29u) & 3u;
        float4 _182;
        if (_164 == 0u)
        {
            _182 = _162.wxyz;
        }
        else
        {
            float4 _181;
            if (_164 == 1u)
            {
                _181 = _162.xwyz;
            }
            else
            {
                float4 _180;
                if (_164 == 2u)
                {
                    _180 = _162.xywz;
                }
                else
                {
                    _180 = _162;
                }
                _181 = _180;
            }
            _182 = _181;
        }
        float4 _78 = gMaterials._m0[_114].mSkinGlobalPose;
        float _199 = precise::min(_78.w, precise::max(_78.z, _78.y + (_129 * _78.x)));
        float4 _79 = float4(gGlobalPoseTransforms._m0[_106].mRotation);
        float3 _205 = (float3(gInitialPositions._m0[_89][1], gInitialPositions._m0[_89][2], gInitialPositions._m0[_89][0]) * float3(gGlobalPoseTransforms._m0[_106].mRotation[0], gGlobalPoseTransforms._m0[_106].mRotation[1], gGlobalPoseTransforms._m0[_106].mRotation[2])) - (float3(gGlobalPoseTransforms._m0[_106].mRotation[1], gGlobalPoseTransforms._m0[_106].mRotation[2], gGlobalPoseTransforms._m0[_106].mRotation[0]) * float3(gInitialPositions._m0[_89]));
        float3 _206 = _205.yzx;
        float3 _215 = (_206 * _79.w) + ((_205.zxy * float3(gGlobalPoseTransforms._m0[_106].mRotation[0], gGlobalPoseTransforms._m0[_106].mRotation[1], gGlobalPoseTransforms._m0[_106].mRotation[2])) - (float3(gGlobalPoseTransforms._m0[_106].mRotation[1], gGlobalPoseTransforms._m0[_106].mRotation[2], gGlobalPoseTransforms._m0[_106].mRotation[0]) * _206)).yzx;
        float4 _80 = float4(gGlobalPoseTransforms._m0[_106].mRotation);
        float4 _81 = _182;
        float4 _315 = float4((((_80.w * _81.x) + (_80.x * _81.w)) + (_80.y * _81.z)) - (_80.z * _81.y), (((_80.w * _81.y) - (_80.x * _81.z)) + (_80.y * _81.w)) + (_80.z * _81.x), (((_80.w * _81.z) + (_80.x * _81.y)) - (_80.y * _81.x)) + (_80.z * _81.w), (((_80.w * _81.w) - (_80.x * _81.x)) - (_80.y * _81.y)) - (_80.z * _81.z)) - _182;
        float4 _82 = gMaterials._m0[_114].mGlobalPose;
        float _329 = precise::min(_82.w, precise::max(_82.z, _82.y + (_129 * _82.x)));
        gPositions._m0[_89] = JPH_HairPosition{ (float3(gInitialPositions._m0[_89]) + (((float3(gGlobalPoseTransforms._m0[_106].mPosition) + (float3(gInitialPositions._m0[_89]) + (_215 + _215))) - float3(gInitialPositions._m0[_89])) * _199)) * _329, fast::normalize((_182 + (_315 * _199)) * _329) };
        break;
    } while(false);
}

