#pragma clang diagnostic ignored "-Wmissing-prototypes"
#pragma clang diagnostic ignored "-Wmissing-braces"

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

template<typename T, size_t Num>
struct spvUnsafeArray
{
    T elements[Num ? Num : 1];
    
    thread T& operator [] (size_t pos) thread
    {
        return elements[pos];
    }
    constexpr const thread T& operator [] (size_t pos) const thread
    {
        return elements[pos];
    }
    
    device T& operator [] (size_t pos) device
    {
        return elements[pos];
    }
    constexpr const device T& operator [] (size_t pos) const device
    {
        return elements[pos];
    }
    
    constexpr const constant T& operator [] (size_t pos) const constant
    {
        return elements[pos];
    }
    
    threadgroup T& operator [] (size_t pos) threadgroup
    {
        return elements[pos];
    }
    constexpr const threadgroup T& operator [] (size_t pos) const threadgroup
    {
        return elements[pos];
    }
};

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

struct type_StructuredBuffer_v3float
{
    packed_float3 _m0[1];
};

struct JPH_HairSkinWeight
{
    uint mJointIdx;
    float mWeight;
};

struct type_StructuredBuffer_JPH_HairSkinWeight
{
    JPH_HairSkinWeight _m0[1];
};

struct type_StructuredBuffer_
{
    float4 _m0[1][4];
};

struct type_RWStructuredBuffer_v3float
{
    packed_float3 _m0[1];
};

struct JPH_HairSkinWeight_1
{
    uint mJointIdx;
    float mWeight;
};

static inline __attribute__((always_inline))
float3 JPH_Mat44Mul3x4Vec3(thread const spvUnsafeArray<float4, 4>& inLHS, thread const float3& inRHS)
{
    return (((inLHS[0].xyz * inRHS.x) + (inLHS[1].xyz * inRHS.y)) + (inLHS[2].xyz * inRHS.z)) + inLHS[3].xyz;
}

static inline __attribute__((always_inline))
void src_main(thread const uint3& tid, constant type_gContext& gContext, device type_StructuredBuffer_v3float& gScalpVertices, device type_StructuredBuffer_JPH_HairSkinWeight& gScalpSkinWeights, device type_StructuredBuffer_& gScalpJointMatrices, device type_RWStructuredBuffer_v3float& gScalpVerticesOut)
{
    uint vtx = tid.x;
    if (vtx >= gContext.cNumSkinVertices)
    {
        return;
    }
    float3 v = float3(0.0);
    uint _85 = vtx * gContext.cNumSkinWeightsPerVertex;
    uint w_end = _85 + gContext.cNumSkinWeightsPerVertex;
    for (uint w = _85; w < w_end; w++)
    {
        JPH_HairSkinWeight_1 sw = JPH_HairSkinWeight_1{ gScalpSkinWeights._m0[w].mJointIdx, gScalpSkinWeights._m0[w].mWeight };
        if (sw.mWeight > 0.0)
        {
            spvUnsafeArray<float4, 4> _119 = spvUnsafeArray<float4, 4>({ gScalpJointMatrices._m0[sw.mJointIdx][0], gScalpJointMatrices._m0[sw.mJointIdx][1], gScalpJointMatrices._m0[sw.mJointIdx][2], gScalpJointMatrices._m0[sw.mJointIdx][3] });
            spvUnsafeArray<float4, 4> param_var_inLHS = _119;
            float3 param_var_inRHS = float3(gScalpVertices._m0[vtx]);
            v += (JPH_Mat44Mul3x4Vec3(param_var_inLHS, param_var_inRHS) * sw.mWeight);
        }
    }
    gScalpVerticesOut._m0[vtx] = v;
}

kernel void HairSkinVertices(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_v3float& gScalpVertices [[buffer(1)]], device type_StructuredBuffer_JPH_HairSkinWeight& gScalpSkinWeights [[buffer(2)]], device type_StructuredBuffer_& gScalpJointMatrices [[buffer(3)]], device type_RWStructuredBuffer_v3float& gScalpVerticesOut [[buffer(4)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    uint3 param_var_tid = gl_GlobalInvocationID;
    src_main(param_var_tid, gContext, gScalpVertices, gScalpSkinWeights, gScalpJointMatrices, gScalpVerticesOut);
}

