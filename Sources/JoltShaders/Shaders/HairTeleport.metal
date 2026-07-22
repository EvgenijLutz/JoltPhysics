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

struct type_StructuredBuffer_uint
{
    uint _m0[1];
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

kernel void HairTeleport(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_v3float& gInitialPositions [[buffer(1)]], device type_StructuredBuffer_uint& gInitialBishops [[buffer(2)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(3)]], device type_RWStructuredBuffer_JPH_HairVelocity& gVelocities [[buffer(4)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        if (gl_GlobalInvocationID.x >= gContext.cNumVertices)
        {
            break;
        }
        float3 _87 = float3(float(int(gInitialBishops._m0[gl_GlobalInvocationID.x] & 511u) - 255), float(int((gInitialBishops._m0[gl_GlobalInvocationID.x] >> 9u) & 511u) - 255), float((gInitialBishops._m0[gl_GlobalInvocationID.x] >> 18u) & 511u) - 255.0) * 0.0027729677967727184295654296875;
        float4 _95 = float4(_87, sqrt(precise::max(1.0 - dot(_87, _87), 0.0)));
        float4 _101;
        if ((gInitialBishops._m0[gl_GlobalInvocationID.x] & 2147483648u) != 0u)
        {
            _101 = -_95;
        }
        else
        {
            _101 = _95;
        }
        uint _103 = (gInitialBishops._m0[gl_GlobalInvocationID.x] >> 29u) & 3u;
        float4 _121;
        if (_103 == 0u)
        {
            _121 = _101.wxyz;
        }
        else
        {
            float4 _120;
            if (_103 == 1u)
            {
                _120 = _101.xwyz;
            }
            else
            {
                float4 _119;
                if (_103 == 2u)
                {
                    _119 = _101.xywz;
                }
                else
                {
                    _119 = _101;
                }
                _120 = _119;
            }
            _121 = _120;
        }
        gPositions._m0[gl_GlobalInvocationID.x] = JPH_HairPosition{ float3(gInitialPositions._m0[gl_GlobalInvocationID.x]), _121 };
        gVelocities._m0[gl_GlobalInvocationID.x] = JPH_HairVelocity{ float3(0.0), float3(0.0) };
        break;
    } while(false);
}

