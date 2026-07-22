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

kernel void HairSkinVertices(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_v3float& gScalpVertices [[buffer(1)]], device type_StructuredBuffer_JPH_HairSkinWeight& gScalpSkinWeights [[buffer(2)]], device type_StructuredBuffer_& gScalpJointMatrices [[buffer(3)]], device type_RWStructuredBuffer_v3float& gScalpVerticesOut [[buffer(4)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        if (gl_GlobalInvocationID.x >= gContext.cNumSkinVertices)
        {
            break;
        }
        uint _61 = gl_GlobalInvocationID.x * gContext.cNumSkinWeightsPerVertex;
        uint _62 = _61 + gContext.cNumSkinWeightsPerVertex;
        float3 _64;
        _64 = float3(0.0);
        float3 _65;
        for (uint _67 = _61; _67 < _62; _64 = _65, _67++)
        {
            if (gScalpSkinWeights._m0[_67].mWeight > 0.0)
            {
                _65 = _64 + (((((gScalpJointMatrices._m0[gScalpSkinWeights._m0[_67].mJointIdx][0u].xyz * gScalpVertices._m0[gl_GlobalInvocationID.x][0]) + (gScalpJointMatrices._m0[gScalpSkinWeights._m0[_67].mJointIdx][1u].xyz * gScalpVertices._m0[gl_GlobalInvocationID.x][1])) + (gScalpJointMatrices._m0[gScalpSkinWeights._m0[_67].mJointIdx][2u].xyz * gScalpVertices._m0[gl_GlobalInvocationID.x][2])) + gScalpJointMatrices._m0[gScalpSkinWeights._m0[_67].mJointIdx][3u].xyz) * gScalpSkinWeights._m0[_67].mWeight);
            }
            else
            {
                _65 = _64;
            }
        }
        gScalpVerticesOut._m0[gl_GlobalInvocationID.x] = _64;
        break;
    } while(false);
}

