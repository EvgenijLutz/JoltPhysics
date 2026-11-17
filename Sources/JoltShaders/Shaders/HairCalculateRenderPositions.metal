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

struct JPH_HairSVertexInfluence
{
    uint mVertexIndex;
    packed_float3 mRelativePosition;
    float mWeight;
};

struct type_StructuredBuffer_JPH_HairSVertexInfluence
{
    JPH_HairSVertexInfluence _m0[1];
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

struct type_RWStructuredBuffer_v3float
{
    packed_float3 _m0[1];
};

struct JPH_HairSVertexInfluence_1
{
    uint mVertexIndex;
    float3 mRelativePosition;
    float mWeight;
};

struct JPH_HairPosition_1
{
    float3 mPosition;
    float4 mRotation;
};

static inline __attribute__((always_inline))
float3 JPH_QuatMulVec3(thread const float4& inLHS, thread const float3& inRHS)
{
    float3 v_xyz = inLHS.xyz;
    float3 v_yzx = inLHS.yzx;
    float3 q_cross_p = ((inRHS.yzx * v_xyz) - (v_yzx * inRHS)).yzx;
    float3 q_cross_q_cross_p = ((q_cross_p.yzx * v_xyz) - (v_yzx * q_cross_p)).yzx;
    float3 v = (q_cross_p * inLHS.w) + q_cross_q_cross_p;
    return inRHS + (v + v);
}

static inline __attribute__((always_inline))
float3 SkinRenderVertex(thread const uint& inVertexIndex, device type_StructuredBuffer_JPH_HairSVertexInfluence& gSVertexInfluences, device type_StructuredBuffer_JPH_HairPosition& gPositions)
{
    float3 out_position = float3(0.0);
    uint _94 = inVertexIndex * 3u;
    uint idx_end = _94 + 3u;
    for (uint idx = _94; idx < idx_end; idx++)
    {
        JPH_HairSVertexInfluence_1 inf = JPH_HairSVertexInfluence_1{ gSVertexInfluences._m0[idx].mVertexIndex, float3(gSVertexInfluences._m0[idx].mRelativePosition), gSVertexInfluences._m0[idx].mWeight };
        JPH_HairPosition_1 sim_vtx = JPH_HairPosition_1{ float3(gPositions._m0[inf.mVertexIndex].mPosition), float4(gPositions._m0[inf.mVertexIndex].mRotation) };
        float4 param_var_inLHS = sim_vtx.mRotation;
        float3 param_var_inRHS = inf.mRelativePosition;
        out_position += ((sim_vtx.mPosition + JPH_QuatMulVec3(param_var_inLHS, param_var_inRHS)) * inf.mWeight);
    }
    return out_position;
}

static inline __attribute__((always_inline))
void src_main(thread const uint3& tid, constant type_gContext& gContext, device type_StructuredBuffer_JPH_HairSVertexInfluence& gSVertexInfluences, device type_StructuredBuffer_JPH_HairPosition& gPositions, device type_RWStructuredBuffer_v3float& gRenderPositions)
{
    uint vtx = tid.x;
    if (vtx >= gContext.cNumRenderVertices)
    {
        return;
    }
    uint param_var_inVertexIndex = vtx;
    float3 out_position = SkinRenderVertex(param_var_inVertexIndex, gSVertexInfluences, gPositions);
    gRenderPositions._m0[vtx] = out_position;
}

kernel void HairCalculateRenderPositions(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_JPH_HairSVertexInfluence& gSVertexInfluences [[buffer(1)]], device type_StructuredBuffer_JPH_HairPosition& gPositions [[buffer(2)]], device type_RWStructuredBuffer_v3float& gRenderPositions [[buffer(3)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    uint3 param_var_tid = gl_GlobalInvocationID;
    src_main(param_var_tid, gContext, gSVertexInfluences, gPositions, gRenderPositions);
}

