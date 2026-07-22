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

struct type_RWStructuredBuffer_JPH_HairPosition
{
    JPH_HairPosition _m0[1];
};

struct type_RWStructuredBuffer_JPH_HairGlobalPoseTransform
{
    JPH_HairGlobalPoseTransform _m0[1];
};

kernel void HairUpdateRoots(constant type_gContext& gContext [[buffer(0)]], constant type_gIterationContext& gIterationContext [[buffer(1)]], device type_StructuredBuffer_JPH_HairPosition& gTargetPositions [[buffer(2)]], device type_StructuredBuffer_JPH_HairGlobalPoseTransform& gTargetGlobalPoseTransforms [[buffer(3)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(4)]], device type_RWStructuredBuffer_JPH_HairGlobalPoseTransform& gGlobalPoseTransforms [[buffer(5)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        if (gl_GlobalInvocationID.x >= gContext.cNumStrands)
        {
            break;
        }
        float _61 = 1.0 - gIterationContext.cIterationFraction;
        gPositions._m0[gl_GlobalInvocationID.x] = JPH_HairPosition{ (float3(gPositions._m0[gl_GlobalInvocationID.x].mPosition) * _61) + (float3(gTargetPositions._m0[gl_GlobalInvocationID.x].mPosition) * gIterationContext.cIterationFraction), fast::normalize((float4(gPositions._m0[gl_GlobalInvocationID.x].mRotation) * _61) + (float4(gTargetPositions._m0[gl_GlobalInvocationID.x].mRotation) * gIterationContext.cIterationFraction)) };
        gGlobalPoseTransforms._m0[gl_GlobalInvocationID.x] = JPH_HairGlobalPoseTransform{ (float3(gGlobalPoseTransforms._m0[gl_GlobalInvocationID.x].mPosition) * _61) + (float3(gTargetGlobalPoseTransforms._m0[gl_GlobalInvocationID.x].mPosition) * gIterationContext.cIterationFraction), fast::normalize((float4(gGlobalPoseTransforms._m0[gl_GlobalInvocationID.x].mRotation) * _61) + (float4(gTargetGlobalPoseTransforms._m0[gl_GlobalInvocationID.x].mRotation) * gIterationContext.cIterationFraction)) };
        break;
    } while(false);
}

