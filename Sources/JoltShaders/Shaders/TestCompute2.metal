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

struct TestCompute2Input_1
{
    spvUnsafeArray<float4, 4> mMat44Value;
    float3 mMat44MulValue;
    uint mCompressedVec3;
    uint mCompressedQuat;
};

struct TestCompute2Output_1
{
    float3 mMul3x4Output;
    float3 mMul3x3Output;
    float3 mDecompressedVec3;
    float4 mDecompressedQuat;
};

static inline __attribute__((always_inline))
float3 JPH_Mat44Mul3x4Vec3(thread const spvUnsafeArray<float4, 4>& inLHS, thread const float3& inRHS)
{
    return (((inLHS[0].xyz * inRHS.x) + (inLHS[1].xyz * inRHS.y)) + (inLHS[2].xyz * inRHS.z)) + inLHS[3].xyz;
}

static inline __attribute__((always_inline))
float3 JPH_Mat44Mul3x3Vec3(thread const spvUnsafeArray<float4, 4>& inLHS, thread const float3& inRHS)
{
    return ((inLHS[0].xyz * inRHS.x) + (inLHS[1].xyz * inRHS.y)) + (inLHS[2].xyz * inRHS.z);
}

static inline __attribute__((always_inline))
float3 JPH_Vec3DecompressUnit(thread const uint& inValue)
{
    // Warning: Unused variable
    //float cOneOverSqrt2 = 0.707106769084930419921875;
    uint cNumBits = 14u;
    uint cMask = 16383u;
    // Warning: Unused variable
    //uint cMaxValue = 16382u;
    int cHalfMaxValue = 8191;
    float cScale = 8.6327279859688133001327514648438e-05;
    float2 v2 = float2(float(int(inValue & cMask) - cHalfMaxValue), float(int((inValue >> (cNumBits & 31u)) & cMask) - cHalfMaxValue)) * cScale;
    float3 v = float3(v2, sqrt(precise::max(1.0 - dot(v2, v2), 0.0)));
    if ((inValue & 2147483648u) != 0u)
    {
        v = -v;
    }
    uint max_element = (inValue >> (29u & 31u)) & 3u;
    float3 temp_var_ternary;
    if (max_element == 0u)
    {
        temp_var_ternary = v.zxy;
    }
    else
    {
        float3 temp_var_ternary_1;
        if (max_element == 1u)
        {
            temp_var_ternary_1 = v.xzy;
        }
        else
        {
            temp_var_ternary_1 = v;
        }
        temp_var_ternary = temp_var_ternary_1;
    }
    v = temp_var_ternary;
    return v;
}

static inline __attribute__((always_inline))
float4 JPH_QuatDecompress(thread const uint& inValue)
{
    // Warning: Unused variable
    //float cOneOverSqrt2 = 0.707106769084930419921875;
    uint cNumBits = 9u;
    uint cMask = 511u;
    // Warning: Unused variable
    //uint cMaxValue = 510u;
    int cHalfMaxValue = 255;
    float cScale = 0.0027729677967727184295654296875;
    float3 v3 = float3(float(int(inValue & cMask) - cHalfMaxValue), float(int((inValue >> (cNumBits & 31u)) & cMask) - cHalfMaxValue), float(uint(int(inValue >> ((2u * cNumBits) & 31u))) & cMask) - 255.0) * cScale;
    float4 v = float4(v3, sqrt(precise::max(1.0 - dot(v3, v3), 0.0)));
    if ((inValue & 2147483648u) != 0u)
    {
        v = -v;
    }
    uint max_element = (inValue >> (29u & 31u)) & 3u;
    float4 temp_var_ternary;
    if (max_element == 0u)
    {
        temp_var_ternary = v.wxyz;
    }
    else
    {
        float4 temp_var_ternary_1;
        if (max_element == 1u)
        {
            temp_var_ternary_1 = v.xwyz;
        }
        else
        {
            float4 temp_var_ternary_2;
            if (max_element == 2u)
            {
                temp_var_ternary_2 = v.xywz;
            }
            else
            {
                temp_var_ternary_2 = v;
            }
            temp_var_ternary_1 = temp_var_ternary_2;
        }
        temp_var_ternary = temp_var_ternary_1;
    }
    v = temp_var_ternary;
    return v;
}

static inline __attribute__((always_inline))
void src_main(thread const uint3& tid, device type_StructuredBuffer_TestCompute2Input& gInput, device type_RWStructuredBuffer_TestCompute2Output& gOutput)
{
    spvUnsafeArray<float4, 4> _85 = spvUnsafeArray<float4, 4>({ float4(gInput._m0[tid.x].mMat44Value[0]), float4(gInput._m0[tid.x].mMat44Value[1]), float4(gInput._m0[tid.x].mMat44Value[2]), float4(gInput._m0[tid.x].mMat44Value[3]) });
    TestCompute2Input_1 _input = TestCompute2Input_1{ _85, float3(gInput._m0[tid.x].mMat44MulValue), gInput._m0[tid.x].mCompressedVec3, gInput._m0[tid.x].mCompressedQuat };
    spvUnsafeArray<float4, 4> param_var_inLHS = _input.mMat44Value;
    float3 param_var_inRHS = _input.mMat44MulValue;
    TestCompute2Output_1 _output;
    _output.mMul3x4Output = JPH_Mat44Mul3x4Vec3(param_var_inLHS, param_var_inRHS);
    spvUnsafeArray<float4, 4> param_var_inLHS_1 = _input.mMat44Value;
    float3 param_var_inRHS_1 = _input.mMat44MulValue;
    _output.mMul3x3Output = JPH_Mat44Mul3x3Vec3(param_var_inLHS_1, param_var_inRHS_1);
    uint param_var_inValue = _input.mCompressedVec3;
    _output.mDecompressedVec3 = JPH_Vec3DecompressUnit(param_var_inValue);
    uint param_var_inValue_1 = _input.mCompressedQuat;
    _output.mDecompressedQuat = JPH_QuatDecompress(param_var_inValue_1);
    gOutput._m0[tid.x] = TestCompute2Output{ _output.mMul3x4Output, _output.mMul3x3Output, _output.mDecompressedVec3, _output.mDecompressedQuat };
}

kernel void TestCompute2(device type_StructuredBuffer_TestCompute2Input& gInput [[buffer(0)]], device type_RWStructuredBuffer_TestCompute2Output& gOutput [[buffer(1)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    uint3 param_var_tid = gl_GlobalInvocationID;
    src_main(param_var_tid, gInput, gOutput);
}

