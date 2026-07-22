#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct TestCompute2Input
{
    packed_float4 mMat44Value[4];
    packed_float3 mMat44MulValue;
    uint mCompressedVec3;
    uint mCompressedQuat;
};

struct type_StructuredBuffer_TestCompute2Input
{
    TestCompute2Input _m0[1];
};

struct TestCompute2Output
{
    packed_float3 mMul3x4Output;
    packed_float3 mMul3x3Output;
    packed_float3 mDecompressedVec3;
    packed_float4 mDecompressedQuat;
};

struct type_RWStructuredBuffer_TestCompute2Output
{
    TestCompute2Output _m0[1];
};

kernel void TestCompute2(device type_StructuredBuffer_TestCompute2Input& gInput [[buffer(0)]], device type_RWStructuredBuffer_TestCompute2Output& gOutput [[buffer(1)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    float3 _81 = ((float3(gInput._m0[gl_GlobalInvocationID.x].mMat44Value[0u][0], gInput._m0[gl_GlobalInvocationID.x].mMat44Value[0u][1], gInput._m0[gl_GlobalInvocationID.x].mMat44Value[0u][2]) * gInput._m0[gl_GlobalInvocationID.x].mMat44MulValue[0]) + (float3(gInput._m0[gl_GlobalInvocationID.x].mMat44Value[1u][0], gInput._m0[gl_GlobalInvocationID.x].mMat44Value[1u][1], gInput._m0[gl_GlobalInvocationID.x].mMat44Value[1u][2]) * gInput._m0[gl_GlobalInvocationID.x].mMat44MulValue[1])) + (float3(gInput._m0[gl_GlobalInvocationID.x].mMat44Value[2u][0], gInput._m0[gl_GlobalInvocationID.x].mMat44Value[2u][1], gInput._m0[gl_GlobalInvocationID.x].mMat44Value[2u][2]) * gInput._m0[gl_GlobalInvocationID.x].mMat44MulValue[2]);
    float2 _94 = float2(float(int(gInput._m0[gl_GlobalInvocationID.x].mCompressedVec3 & 16383u) - 8191), float(int((gInput._m0[gl_GlobalInvocationID.x].mCompressedVec3 >> 14u) & 16383u) - 8191)) * 8.6327279859688133001327514648438e-05;
    float3 _101 = float3(_94, sqrt(precise::max(1.0 - dot(_94, _94), 0.0)));
    float3 _107;
    if ((gInput._m0[gl_GlobalInvocationID.x].mCompressedVec3 & 2147483648u) != 0u)
    {
        _107 = -_101;
    }
    else
    {
        _107 = _101;
    }
    uint _109 = (gInput._m0[gl_GlobalInvocationID.x].mCompressedVec3 >> 29u) & 3u;
    float3 _121;
    if (_109 == 0u)
    {
        _121 = _107.zxy;
    }
    else
    {
        float3 _120;
        if (_109 == 1u)
        {
            _120 = _107.xzy;
        }
        else
        {
            _120 = _107;
        }
        _121 = _120;
    }
    float3 _136 = float3(float(int(gInput._m0[gl_GlobalInvocationID.x].mCompressedQuat & 511u) - 255), float(int((gInput._m0[gl_GlobalInvocationID.x].mCompressedQuat >> 9u) & 511u) - 255), float((gInput._m0[gl_GlobalInvocationID.x].mCompressedQuat >> 18u) & 511u) - 255.0) * 0.0027729677967727184295654296875;
    float4 _144 = float4(_136, sqrt(precise::max(1.0 - dot(_136, _136), 0.0)));
    float4 _150;
    if ((gInput._m0[gl_GlobalInvocationID.x].mCompressedQuat & 2147483648u) != 0u)
    {
        _150 = -_144;
    }
    else
    {
        _150 = _144;
    }
    uint _152 = (gInput._m0[gl_GlobalInvocationID.x].mCompressedQuat >> 29u) & 3u;
    float4 _170;
    if (_152 == 0u)
    {
        _170 = _150.wxyz;
    }
    else
    {
        float4 _169;
        if (_152 == 1u)
        {
            _169 = _150.xwyz;
        }
        else
        {
            float4 _168;
            if (_152 == 2u)
            {
                _168 = _150.xywz;
            }
            else
            {
                _168 = _150;
            }
            _169 = _168;
        }
        _170 = _169;
    }
    gOutput._m0[gl_GlobalInvocationID.x] = TestCompute2Output{ _81 + float3(gInput._m0[gl_GlobalInvocationID.x].mMat44Value[3u][0], gInput._m0[gl_GlobalInvocationID.x].mMat44Value[3u][1], gInput._m0[gl_GlobalInvocationID.x].mMat44Value[3u][2]), _81, _121, _170 };
}

