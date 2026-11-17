#pragma clang diagnostic ignored "-Wmissing-prototypes"

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

struct JPH_HairPosition_1
{
    float3 mPosition;
    float4 mRotation;
};

struct JPH_HairGlobalPoseTransform_1
{
    float3 mPosition;
    float4 mRotation;
};

static inline __attribute__((always_inline))
void src_main(thread const uint3& tid, constant type_gContext& gContext, constant type_gIterationContext& gIterationContext, device type_StructuredBuffer_JPH_HairPosition& gTargetPositions, device type_StructuredBuffer_JPH_HairGlobalPoseTransform& gTargetGlobalPoseTransforms, device type_RWStructuredBuffer_JPH_HairPosition& gPositions, device type_RWStructuredBuffer_JPH_HairGlobalPoseTransform& gGlobalPoseTransforms)
{
    uint strand_idx = tid.x;
    if (strand_idx >= gContext.cNumStrands)
    {
        return;
    }
    float inv_fraction = 1.0 - gIterationContext.cIterationFraction;
    JPH_HairPosition_1 pos = JPH_HairPosition_1{ float3(gPositions._m0[strand_idx].mPosition), float4(gPositions._m0[strand_idx].mRotation) };
    JPH_HairPosition_1 target_pos = JPH_HairPosition_1{ float3(gTargetPositions._m0[strand_idx].mPosition), float4(gTargetPositions._m0[strand_idx].mRotation) };
    pos.mPosition = (pos.mPosition * inv_fraction) + (target_pos.mPosition * gIterationContext.cIterationFraction);
    pos.mRotation = fast::normalize((pos.mRotation * inv_fraction) + (target_pos.mRotation * gIterationContext.cIterationFraction));
    gPositions._m0[strand_idx] = JPH_HairPosition{ pos.mPosition, pos.mRotation };
    JPH_HairGlobalPoseTransform_1 transf = JPH_HairGlobalPoseTransform_1{ float3(gGlobalPoseTransforms._m0[strand_idx].mPosition), float4(gGlobalPoseTransforms._m0[strand_idx].mRotation) };
    JPH_HairGlobalPoseTransform_1 target_transf = JPH_HairGlobalPoseTransform_1{ float3(gTargetGlobalPoseTransforms._m0[strand_idx].mPosition), float4(gTargetGlobalPoseTransforms._m0[strand_idx].mRotation) };
    transf.mPosition = (transf.mPosition * inv_fraction) + (target_transf.mPosition * gIterationContext.cIterationFraction);
    transf.mRotation = fast::normalize((transf.mRotation * inv_fraction) + (target_transf.mRotation * gIterationContext.cIterationFraction));
    gGlobalPoseTransforms._m0[strand_idx] = JPH_HairGlobalPoseTransform{ transf.mPosition, transf.mRotation };
}

kernel void HairUpdateRoots(constant type_gContext& gContext [[buffer(0)]], constant type_gIterationContext& gIterationContext [[buffer(1)]], device type_StructuredBuffer_JPH_HairPosition& gTargetPositions [[buffer(2)]], device type_StructuredBuffer_JPH_HairGlobalPoseTransform& gTargetGlobalPoseTransforms [[buffer(3)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(4)]], device type_RWStructuredBuffer_JPH_HairGlobalPoseTransform& gGlobalPoseTransforms [[buffer(5)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    uint3 param_var_tid = gl_GlobalInvocationID;
    src_main(param_var_tid, gContext, gIterationContext, gTargetPositions, gTargetGlobalPoseTransforms, gPositions, gGlobalPoseTransforms);
}

