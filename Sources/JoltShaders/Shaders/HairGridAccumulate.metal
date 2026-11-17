#pragma clang diagnostic ignored "-Wunused-variable"

#include <metal_stdlib>
#include <simd/simd.h>
#include <metal_atomic>

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

struct JPH_HairPosition
{
    packed_float3 mPosition;
    packed_float4 mRotation;
};

struct type_StructuredBuffer_JPH_HairPosition
{
    JPH_HairPosition _m0[1];
};

struct JPH_HairVelocity
{
    packed_float3 mVelocity;
    packed_float3 mAngularVelocity;
};

struct type_StructuredBuffer_JPH_HairVelocity
{
    JPH_HairVelocity _m0[1];
};

struct type_RWStructuredBuffer_v4int
{
    int4 _m0[1];
};

kernel void HairGridAccumulate(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_uint& gVerticesFixed [[buffer(1)]], device type_StructuredBuffer_JPH_HairPosition& gPositions [[buffer(2)]], device type_StructuredBuffer_JPH_HairVelocity& gVelocities [[buffer(3)]], device type_RWStructuredBuffer_v4int& gVelocityAndDensity [[buffer(4)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        uint _86 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_86 >= gContext.cNumVertices)
        {
            break;
        }
        if ((gVerticesFixed._m0[_86 >> 5u] & (1u << (_86 & 31u))) != 0u)
        {
            break;
        }
        float3 _112 = precise::min(precise::max(float3(gPositions._m0[_86].mPosition) - float3(gContext.cGridOffset), float3(0.0)) * float3(gContext.cGridScale), float3(gContext.cGridSizeMin1));
        uint3 _116 = min(uint3(_112), uint3(gContext.cGridSizeMin2));
        float3 _118 = _112 - float3(_116);
        float3 _68 = _118;
        float3 _69 = float3(1.0) - _118;
        float3 _121 = float3(gVelocities._m0[_86].mVelocity);
        float4 _126 = float4(_121, 1.0) * 1024.0;
        uint3 _70 = uint3(gContext.cGridStride);
        uint3 _71 = _116;
        uint _142 = (_71.x + (_71.y * gContext.cGridStride[1])) + (_71.z * gContext.cGridStride[2]);
        uint _143 = _142 + 1u;
        uint _146 = _142 + _70.y;
        uint _147 = _146 + 1u;
        int4 _72 = int4(rint(_126 * ((_69.x * _69.y) * _69.z)));
        int _162 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_142])[0], _72.x, memory_order_relaxed);
        int _166 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_142])[1], _72.y, memory_order_relaxed);
        int _170 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_142])[2], _72.z, memory_order_relaxed);
        int _174 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_142])[3], _72.w, memory_order_relaxed);
        int4 _73 = int4(rint(_126 * ((_68.x * _69.y) * _69.z)));
        int _189 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_143])[0], _73.x, memory_order_relaxed);
        int _193 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_143])[1], _73.y, memory_order_relaxed);
        int _197 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_143])[2], _73.z, memory_order_relaxed);
        int _201 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_143])[3], _73.w, memory_order_relaxed);
        int4 _74 = int4(rint(_126 * ((_69.x * _68.y) * _69.z)));
        int _216 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_146])[0], _74.x, memory_order_relaxed);
        int _220 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_146])[1], _74.y, memory_order_relaxed);
        int _224 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_146])[2], _74.z, memory_order_relaxed);
        int _228 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_146])[3], _74.w, memory_order_relaxed);
        int4 _75 = int4(rint(_126 * ((_68.x * _68.y) * _69.z)));
        int _243 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_147])[0], _75.x, memory_order_relaxed);
        int _247 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_147])[1], _75.y, memory_order_relaxed);
        int _251 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_147])[2], _75.z, memory_order_relaxed);
        int _255 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_147])[3], _75.w, memory_order_relaxed);
        uint _258 = _142 + _70.z;
        int4 _76 = int4(rint(_126 * ((_69.x * _69.y) * _68.z)));
        int _273 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_258])[0], _76.x, memory_order_relaxed);
        int _277 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_258])[1], _76.y, memory_order_relaxed);
        int _281 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_258])[2], _76.z, memory_order_relaxed);
        int _285 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_258])[3], _76.w, memory_order_relaxed);
        uint _288 = _143 + _70.z;
        int4 _77 = int4(rint(_126 * ((_68.x * _69.y) * _68.z)));
        int _303 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_288])[0], _77.x, memory_order_relaxed);
        int _307 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_288])[1], _77.y, memory_order_relaxed);
        int _311 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_288])[2], _77.z, memory_order_relaxed);
        int _315 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_288])[3], _77.w, memory_order_relaxed);
        uint _318 = _146 + _70.z;
        int4 _78 = int4(rint(_126 * ((_69.x * _68.y) * _68.z)));
        int _333 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_318])[0], _78.x, memory_order_relaxed);
        int _337 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_318])[1], _78.y, memory_order_relaxed);
        int _341 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_318])[2], _78.z, memory_order_relaxed);
        int _345 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_318])[3], _78.w, memory_order_relaxed);
        uint _348 = _147 + _70.z;
        int4 _79 = int4(rint(_126 * ((_68.x * _68.y) * _68.z)));
        int _363 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_348])[0], _79.x, memory_order_relaxed);
        int _367 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_348])[1], _79.y, memory_order_relaxed);
        int _371 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_348])[2], _79.z, memory_order_relaxed);
        int _375 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_348])[3], _79.w, memory_order_relaxed);
        break;
    } while(false);
}

