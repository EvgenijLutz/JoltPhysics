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

kernel void HairCalculateRenderPositions(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_JPH_HairSVertexInfluence& gSVertexInfluences [[buffer(1)]], device type_StructuredBuffer_JPH_HairPosition& gPositions [[buffer(2)]], device type_RWStructuredBuffer_v3float& gRenderPositions [[buffer(3)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        if (gl_GlobalInvocationID.x >= gContext.cNumRenderVertices)
        {
            break;
        }
        uint _57 = gl_GlobalInvocationID.x * 3u;
        uint _58 = _57 + 3u;
        float3 _60;
        _60 = float3(0.0);
        for (uint _63 = _57; _63 < _58; )
        {
            float3 _84 = (float3(gSVertexInfluences._m0[_63].mRelativePosition[1], gSVertexInfluences._m0[_63].mRelativePosition[2], gSVertexInfluences._m0[_63].mRelativePosition[0]) * float3(gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[0], gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[1], gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[2])) - (float3(gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[1], gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[2], gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[0]) * float3(gSVertexInfluences._m0[_63].mRelativePosition));
            float3 _85 = _84.yzx;
            float3 _93 = (_85 * gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[3]) + ((_84.zxy * float3(gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[0], gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[1], gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[2])) - (float3(gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[1], gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[2], gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mRotation[0]) * _85)).yzx;
            _60 += ((float3(gPositions._m0[gSVertexInfluences._m0[_63].mVertexIndex].mPosition) + (float3(gSVertexInfluences._m0[_63].mRelativePosition) + (_93 + _93))) * gSVertexInfluences._m0[_63].mWeight);
            _63++;
            continue;
        }
        gRenderPositions._m0[gl_GlobalInvocationID.x] = _60;
        break;
    } while(false);
}

