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
        uint _68 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_68 >= gContext.cNumVertices)
        {
            break;
        }
        if ((gVerticesFixed._m0[_68 >> 5u] & (1u << (_68 & 31u))) != 0u)
        {
            break;
        }
        float3 _84 = float3(gPositions._m0[_68].mPosition);
        float3 _94 = precise::min(precise::max(_84 - float3(gContext.cGridOffset), float3(0.0)) * float3(gContext.cGridScale), float3(gContext.cGridSizeMin1));
        uint3 _98 = min(uint3(_94), uint3(gContext.cGridSizeMin2));
        float3 _100 = _94 - float3(_98);
        float3 _101 = float3(1.0) - _100;
        float3 _103 = float3(gVelocities._m0[_68].mVelocity);
        float4 _108 = float4(_103, 1.0) * 1024.0;
        uint _121 = (_98.x + (_98.y * gContext.cGridStride[1])) + (_98.z * gContext.cGridStride[2]);
        uint _122 = _121 + 1u;
        uint _124 = _121 + gContext.cGridStride[1];
        uint _125 = _124 + 1u;
        float _126 = _101.x;
        float _127 = _101.y;
        float _128 = _126 * _127;
        float _129 = _101.z;
        int4 _133 = int4(rint(_108 * (_128 * _129)));
        int _136 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_121])[0], _133.x, memory_order_relaxed);
        int _139 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_121])[1], _133.y, memory_order_relaxed);
        int _142 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_121])[2], _133.z, memory_order_relaxed);
        int _145 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_121])[3], _133.w, memory_order_relaxed);
        float _146 = _100.x;
        float _147 = _146 * _127;
        int4 _151 = int4(rint(_108 * (_147 * _129)));
        int _154 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_122])[0], _151.x, memory_order_relaxed);
        int _157 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_122])[1], _151.y, memory_order_relaxed);
        int _160 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_122])[2], _151.z, memory_order_relaxed);
        int _163 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_122])[3], _151.w, memory_order_relaxed);
        float _164 = _100.y;
        float _165 = _126 * _164;
        int4 _169 = int4(rint(_108 * (_165 * _129)));
        int _172 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_124])[0], _169.x, memory_order_relaxed);
        int _175 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_124])[1], _169.y, memory_order_relaxed);
        int _178 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_124])[2], _169.z, memory_order_relaxed);
        int _181 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_124])[3], _169.w, memory_order_relaxed);
        float _182 = _146 * _164;
        int4 _186 = int4(rint(_108 * (_182 * _129)));
        int _189 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_125])[0], _186.x, memory_order_relaxed);
        int _192 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_125])[1], _186.y, memory_order_relaxed);
        int _195 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_125])[2], _186.z, memory_order_relaxed);
        int _198 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_125])[3], _186.w, memory_order_relaxed);
        uint _200 = _121 + gContext.cGridStride[2];
        float _201 = _100.z;
        int4 _205 = int4(rint(_108 * (_128 * _201)));
        int _208 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_200])[0], _205.x, memory_order_relaxed);
        int _211 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_200])[1], _205.y, memory_order_relaxed);
        int _214 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_200])[2], _205.z, memory_order_relaxed);
        int _217 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_200])[3], _205.w, memory_order_relaxed);
        uint _218 = _122 + gContext.cGridStride[2];
        int4 _222 = int4(rint(_108 * (_147 * _201)));
        int _225 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_218])[0], _222.x, memory_order_relaxed);
        int _228 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_218])[1], _222.y, memory_order_relaxed);
        int _231 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_218])[2], _222.z, memory_order_relaxed);
        int _234 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_218])[3], _222.w, memory_order_relaxed);
        uint _235 = _124 + gContext.cGridStride[2];
        int4 _239 = int4(rint(_108 * (_165 * _201)));
        int _242 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_235])[0], _239.x, memory_order_relaxed);
        int _245 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_235])[1], _239.y, memory_order_relaxed);
        int _248 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_235])[2], _239.z, memory_order_relaxed);
        int _251 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_235])[3], _239.w, memory_order_relaxed);
        uint _252 = _125 + gContext.cGridStride[2];
        int4 _256 = int4(rint(_108 * (_182 * _201)));
        int _259 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_252])[0], _256.x, memory_order_relaxed);
        int _262 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_252])[1], _256.y, memory_order_relaxed);
        int _265 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_252])[2], _256.z, memory_order_relaxed);
        int _268 = atomic_fetch_add_explicit((device atomic_int*)&((device int*)&gVelocityAndDensity._m0[_252])[3], _256.w, memory_order_relaxed);
        break;
    } while(false);
}

