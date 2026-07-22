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

struct type_RWStructuredBuffer_v4int
{
    int4 _m0[1];
};

kernel void HairGridNormalize(constant type_gContext& gContext [[buffer(0)]], device type_RWStructuredBuffer_v4int& gVelocityAndDensity [[buffer(1)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        if (gl_GlobalInvocationID.x >= gContext.cNumGridPoints)
        {
            break;
        }
        float4 _43 = float4(gVelocityAndDensity._m0[gl_GlobalInvocationID.x]) * 0.0009765625;
        float _44 = _43.w;
        float4 _57;
        if (_44 > 9.9999999600419720025001879548654e-13)
        {
            float4 _50 = _43;
            _50.x = _43.x / _44;
            _50.y = _43.y / _44;
            _50.z = _43.z / _44;
            _57 = _50;
        }
        else
        {
            _57 = _43;
        }
        gVelocityAndDensity._m0[gl_GlobalInvocationID.x] = as_type<int4>(_57);
        break;
    } while(false);
}

