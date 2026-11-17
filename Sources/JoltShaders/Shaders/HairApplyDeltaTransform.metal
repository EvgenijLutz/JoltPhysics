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

kernel void HairApplyDeltaTransform(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_uint& gVerticesFixed [[buffer(1)]], device type_StructuredBuffer_uint& gStrandFractions [[buffer(2)]], device type_StructuredBuffer_uint& gStrandMaterialIndex [[buffer(3)]], device type_StructuredBuffer_JPH_HairMaterial& gMaterials [[buffer(4)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(5)]], device type_RWStructuredBuffer_JPH_HairVelocity& gVelocities [[buffer(6)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        uint _80 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_80 >= gContext.cNumVertices)
        {
            break;
        }
        if ((gVerticesFixed._m0[_80 >> 5u] & (1u << (_80 & 31u))) != 0u)
        {
            break;
        }
        uint _97 = _80 % gContext.cNumStrands;
        float4 _68 = gMaterials._m0[(gStrandMaterialIndex._m0[_97 >> 2u] >> (((_97 & 3u) << 3u) & 31u)) & 255u].mWorldTransformInfluence;
        float _140 = precise::min(_68.w, precise::max(_68.z, _68.y + ((float((gStrandFractions._m0[_80 >> 2u] >> (((_80 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125) * _68.x)));
        float3 _69 = float3(gPositions._m0[_80].mPosition);
        float4 _70 = (gContext.cDeltaTransformQuat * _140) + float4(0.0, 0.0, 0.0, 1.0 - _140);
        float4 _71 = float4(gPositions._m0[_80].mRotation);
        float4 _268 = fast::normalize(float4((((_70.w * _71.x) + (_70.x * _71.w)) + (_70.y * _71.z)) - (_70.z * _71.y), (((_70.w * _71.y) - (_70.x * _71.z)) + (_70.y * _71.w)) + (_70.z * _71.x), (((_70.w * _71.z) + (_70.x * _71.y)) - (_70.y * _71.x)) + (_70.z * _71.w), (((_70.w * _71.w) - (_70.x * _71.x)) - (_70.y * _71.y)) - (_70.z * _71.z)));
        float3 _72 = float3(gVelocities._m0[_80].mVelocity);
        float3 _73 = float3(gVelocities._m0[_80].mAngularVelocity);
        gPositions._m0[_80] = JPH_HairPosition{ float3(gPositions._m0[_80].mPosition) + ((((((gContext.cDeltaTransform[0u].xyz * _69.x) + (gContext.cDeltaTransform[1u].xyz * _69.y)) + (gContext.cDeltaTransform[2u].xyz * _69.z)) + gContext.cDeltaTransform[3u].xyz) - float3(gPositions._m0[_80].mPosition)) * _140), _268 };
        gVelocities._m0[_80] = JPH_HairVelocity{ ((gContext.cDeltaTransform[0u].xyz * _72.x) + (gContext.cDeltaTransform[1u].xyz * _72.y)) + (gContext.cDeltaTransform[2u].xyz * _72.z), ((gContext.cDeltaTransform[0u].xyz * _73.x) + (gContext.cDeltaTransform[1u].xyz * _73.y)) + (gContext.cDeltaTransform[2u].xyz * _73.z) };
        break;
    } while(false);
}

