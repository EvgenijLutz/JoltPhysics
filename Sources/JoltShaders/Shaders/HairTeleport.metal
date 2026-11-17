#pragma clang diagnostic ignored "-Wmissing-prototypes"

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

struct type_gIterationContext
{
    float cAccumulatedDeltaTime;
    float cIterationFraction;
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

struct JPH_HairPosition_1
{
    float3 mPosition;
    float4 mRotation;
};

struct JPH_HairVelocity_1
{
    float3 mVelocity;
    float3 mAngularVelocity;
};

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
void src_main(thread const uint3& tid, constant type_gContext& gContext, device type_StructuredBuffer_v3float& gInitialPositions, device type_StructuredBuffer_uint& gInitialBishops, device type_RWStructuredBuffer_JPH_HairPosition& gPositions, device type_RWStructuredBuffer_JPH_HairVelocity& gVelocities)
{
    uint vtx = tid.x;
    if (vtx >= gContext.cNumVertices)
    {
        return;
    }
    JPH_HairPosition_1 pos;
    pos.mPosition = float3(gInitialPositions._m0[vtx]);
    uint param_var_inValue = gInitialBishops._m0[vtx];
    pos.mRotation = JPH_QuatDecompress(param_var_inValue);
    gPositions._m0[vtx] = JPH_HairPosition{ pos.mPosition, pos.mRotation };
    JPH_HairVelocity_1 vel;
    vel.mVelocity = float3(0.0);
    vel.mAngularVelocity = float3(0.0);
    gVelocities._m0[vtx] = JPH_HairVelocity{ vel.mVelocity, vel.mAngularVelocity };
}

kernel void HairTeleport(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_v3float& gInitialPositions [[buffer(1)]], device type_StructuredBuffer_uint& gInitialBishops [[buffer(2)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(3)]], device type_RWStructuredBuffer_JPH_HairVelocity& gVelocities [[buffer(4)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    uint3 param_var_tid = gl_GlobalInvocationID;
    src_main(param_var_tid, gContext, gInitialPositions, gInitialBishops, gPositions, gVelocities);
}

