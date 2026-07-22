#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct type_gContext
{
    packed_float3 cFloat3Value;
    uint cUIntValue;
    packed_float3 cFloat3Value2;
    uint cUIntValue2;
    uint cNumElements;
};

struct type_StructuredBuffer_uint
{
    uint _m0[1];
};

struct type_RWStructuredBuffer_uint
{
    uint _m0[1];
};

kernel void TestCompute(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_uint& gUploadData [[buffer(1)]], device type_StructuredBuffer_uint& gOptionalData [[buffer(2)]], device type_RWStructuredBuffer_uint& gData [[buffer(3)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        if (gl_GlobalInvocationID.x >= gContext.cNumElements)
        {
            break;
        }
        if (gContext.cUIntValue2 == 0u)
        {
            gData._m0[gl_GlobalInvocationID.x] = (gOptionalData._m0[gl_GlobalInvocationID.x] + uint(int(gContext.cFloat3Value2[1]))) + gUploadData._m0[0u];
        }
        else
        {
            gData._m0[gl_GlobalInvocationID.x] = (gData._m0[gl_GlobalInvocationID.x] + gContext.cUIntValue) * gContext.cUIntValue2;
        }
        break;
    } while(false);
}

