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
        uint _67 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_67 >= gContext.cNumVertices)
        {
            break;
        }
        if ((gVerticesFixed._m0[_67 >> 5u] & (1u << (_67 & 31u))) != 0u)
        {
            break;
        }
        uint _82 = _67 % gContext.cNumStrands;
        uint _90 = (gStrandMaterialIndex._m0[_82 >> 2u] >> (((_82 & 3u) << 3u) & 31u)) & 255u;
        float3 _110 = float3(gVelocities._m0[_67].mVelocity);
        float3 _112 = float3(gVelocities._m0[_67].mAngularVelocity);
        float _120 = precise::min(gMaterials._m0[_90].mWorldTransformInfluence.w, precise::max(gMaterials._m0[_90].mWorldTransformInfluence.z, gMaterials._m0[_90].mWorldTransformInfluence.y + ((float((gStrandFractions._m0[_67 >> 2u] >> (((_67 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125) * gMaterials._m0[_90].mWorldTransformInfluence.x)));
        float4 _150 = (gContext.cDeltaTransformQuat * _120) + float4(0.0, 0.0, 0.0, 1.0 - _120);
        float _151 = _150.w;
        float _154 = _150.x;
        float _158 = _150.y;
        float _162 = _150.z;
        gPositions._m0[_67] = JPH_HairPosition{ float3(gPositions._m0[_67].mPosition) + ((((((gContext.cDeltaTransform[0u].xyz * gPositions._m0[_67].mPosition[0]) + (gContext.cDeltaTransform[1u].xyz * gPositions._m0[_67].mPosition[1])) + (gContext.cDeltaTransform[2u].xyz * gPositions._m0[_67].mPosition[2])) + gContext.cDeltaTransform[3u].xyz) - float3(gPositions._m0[_67].mPosition)) * _120), fast::normalize(float4((((_151 * gPositions._m0[_67].mRotation[0]) + (_154 * gPositions._m0[_67].mRotation[3])) + (_158 * gPositions._m0[_67].mRotation[2])) - (_162 * gPositions._m0[_67].mRotation[1]), (((_151 * gPositions._m0[_67].mRotation[1]) - (_154 * gPositions._m0[_67].mRotation[2])) + (_158 * gPositions._m0[_67].mRotation[3])) + (_162 * gPositions._m0[_67].mRotation[0]), (((_151 * gPositions._m0[_67].mRotation[2]) + (_154 * gPositions._m0[_67].mRotation[1])) - (_158 * gPositions._m0[_67].mRotation[0])) + (_162 * gPositions._m0[_67].mRotation[3]), (((_151 * gPositions._m0[_67].mRotation[3]) - (_154 * gPositions._m0[_67].mRotation[0])) - (_158 * gPositions._m0[_67].mRotation[1])) - (_162 * gPositions._m0[_67].mRotation[2]))) };
        gVelocities._m0[_67] = JPH_HairVelocity{ ((gContext.cDeltaTransform[0u].xyz * _110.x) + (gContext.cDeltaTransform[1u].xyz * _110.y)) + (gContext.cDeltaTransform[2u].xyz * _110.z), ((gContext.cDeltaTransform[0u].xyz * _112.x) + (gContext.cDeltaTransform[1u].xyz * _112.y)) + (gContext.cDeltaTransform[2u].xyz * _112.z) };
        break;
    } while(false);
}

