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

// Warning: Unused variable
//constant float4 _46 = {};

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

struct JPH_HairSkinPoint
{
    uint mTriangleIndex;
    float mU;
    float mV;
    uint mToBishop;
};

struct type_StructuredBuffer_JPH_HairSkinPoint
{
    JPH_HairSkinPoint _m0[1];
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

struct JPH_HairGlobalPoseTransform
{
    packed_float3 mPosition;
    packed_float4 mRotation;
};

struct type_RWStructuredBuffer_JPH_HairGlobalPoseTransform
{
    JPH_HairGlobalPoseTransform _m0[1];
};

struct JPH_HairSkinPoint_1
{
    uint mTriangleIndex;
    float mU;
    float mV;
    uint mToBishop;
};

struct JPH_HairPosition_1
{
    float3 mPosition;
    float4 mRotation;
};

struct JPH_HairGlobalPoseTransform_1
{
    float3 mPosition;
    float4 mRotation;
};

static inline __attribute__((always_inline))
float3 JPH_Mat44Mul3x3Vec3(thread const spvUnsafeArray<float4, 4>& inLHS, thread const float3& inRHS)
{
    return ((inLHS[0].xyz * inRHS.x) + (inLHS[1].xyz * inRHS.y)) + (inLHS[2].xyz * inRHS.z);
}

static inline __attribute__((always_inline))
float4 JPH_QuatFromMat33(thread const float3& inCol0, thread const float3& inCol1, thread const float3& inCol2)
{
    float tr = (inCol0.x + inCol1.y) + inCol2.z;
    if (tr >= 0.0)
    {
        float s = sqrt(tr + 1.0);
        float is = 0.5 / s;
        return float4((inCol1.z - inCol2.y) * is, (inCol2.x - inCol0.z) * is, (inCol0.y - inCol1.x) * is, 0.5 * s);
    }
    else
    {
        bool temp_var_logical = false;
        if (inCol0.x > inCol1.y)
        {
            temp_var_logical = inCol0.x > inCol2.z;
        }
        if (temp_var_logical)
        {
            float s_1 = sqrt((inCol0.x - (inCol1.y + inCol2.z)) + 1.0);
            float is_1 = 0.5 / s_1;
            return float4(0.5 * s_1, (inCol1.x + inCol0.y) * is_1, (inCol0.z + inCol2.x) * is_1, (inCol1.z - inCol2.y) * is_1);
        }
        else
        {
            if (inCol1.y > inCol2.z)
            {
                float s_2 = sqrt((inCol1.y - (inCol2.z + inCol0.x)) + 1.0);
                float is_2 = 0.5 / s_2;
                return float4((inCol1.x + inCol0.y) * is_2, 0.5 * s_2, (inCol2.y + inCol1.z) * is_2, (inCol2.x - inCol0.z) * is_2);
            }
            else
            {
                float s_3 = sqrt((inCol2.z - (inCol0.x + inCol1.y)) + 1.0);
                float is_3 = 0.5 / s_3;
                return float4((inCol0.z + inCol2.x) * is_3, (inCol2.y + inCol1.z) * is_3, 0.5 * s_3, (inCol0.y - inCol1.x) * is_3);
            }
        }
    }
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
float4 JPH_QuatMulQuat(thread const float4& inLHS, thread const float4& inRHS)
{
    float x = (((inLHS.w * inRHS.x) + (inLHS.x * inRHS.w)) + (inLHS.y * inRHS.z)) - (inLHS.z * inRHS.y);
    float y = (((inLHS.w * inRHS.y) - (inLHS.x * inRHS.z)) + (inLHS.y * inRHS.w)) + (inLHS.z * inRHS.x);
    float z = (((inLHS.w * inRHS.z) + (inLHS.x * inRHS.y)) - (inLHS.y * inRHS.x)) + (inLHS.z * inRHS.w);
    float w = (((inLHS.w * inRHS.w) - (inLHS.x * inRHS.x)) - (inLHS.y * inRHS.y)) - (inLHS.z * inRHS.z);
    return float4(x, y, z, w);
}

static inline __attribute__((always_inline))
float4 JPH_QuatConjugate(thread const float4& inRotation)
{
    return float4(-inRotation.x, -inRotation.y, -inRotation.z, inRotation.w);
}

static inline __attribute__((always_inline))
float3 JPH_QuatMulVec3(thread const float4& inLHS, thread const float3& inRHS)
{
    float3 v_xyz = inLHS.xyz;
    float3 v_yzx = inLHS.yzx;
    float3 q_cross_p = ((inRHS.yzx * v_xyz) - (v_yzx * inRHS)).yzx;
    float3 q_cross_q_cross_p = ((q_cross_p.yzx * v_xyz) - (v_yzx * q_cross_p)).yzx;
    float3 v = (q_cross_p * inLHS.w) + q_cross_q_cross_p;
    return inRHS + (v + v);
}

static inline __attribute__((always_inline))
void src_main(thread const uint3& tid, constant type_gContext& gContext, device type_StructuredBuffer_JPH_HairSkinPoint& gSkinPoints, device type_StructuredBuffer_v3float& gScalpVertices, device type_StructuredBuffer_uint& gScalpTriangles, device type_StructuredBuffer_v3float& gInitialPositions, device type_StructuredBuffer_uint& gInitialBishops, device type_RWStructuredBuffer_JPH_HairPosition& gPositions, device type_RWStructuredBuffer_JPH_HairGlobalPoseTransform& gGlobalPoseTransforms)
{
    uint strand_idx = tid.x;
    if (strand_idx >= gContext.cNumStrands)
    {
        return;
    }
    JPH_HairSkinPoint_1 sp = JPH_HairSkinPoint_1{ gSkinPoints._m0[strand_idx].mTriangleIndex, gSkinPoints._m0[strand_idx].mU, gSkinPoints._m0[strand_idx].mV, gSkinPoints._m0[strand_idx].mToBishop };
    uint tri_idx = sp.mTriangleIndex * 3u;
    spvUnsafeArray<float4, 4> _155 = spvUnsafeArray<float4, 4>({ gContext.cScalpToHead[0], gContext.cScalpToHead[1], gContext.cScalpToHead[2], gContext.cScalpToHead[3] });
    spvUnsafeArray<float4, 4> param_var_inLHS = _155;
    float3 param_var_inRHS = float3(gScalpVertices._m0[gScalpTriangles._m0[tri_idx + 0u]]);
    float3 v0 = JPH_Mat44Mul3x3Vec3(param_var_inLHS, param_var_inRHS);
    spvUnsafeArray<float4, 4> _172 = spvUnsafeArray<float4, 4>({ gContext.cScalpToHead[0], gContext.cScalpToHead[1], gContext.cScalpToHead[2], gContext.cScalpToHead[3] });
    spvUnsafeArray<float4, 4> param_var_inLHS_1 = _172;
    float3 param_var_inRHS_1 = float3(gScalpVertices._m0[gScalpTriangles._m0[tri_idx + 1u]]);
    float3 v1 = JPH_Mat44Mul3x3Vec3(param_var_inLHS_1, param_var_inRHS_1);
    spvUnsafeArray<float4, 4> _187 = spvUnsafeArray<float4, 4>({ gContext.cScalpToHead[0], gContext.cScalpToHead[1], gContext.cScalpToHead[2], gContext.cScalpToHead[3] });
    spvUnsafeArray<float4, 4> param_var_inLHS_2 = _187;
    float3 param_var_inRHS_2 = float3(gScalpVertices._m0[gScalpTriangles._m0[tri_idx + 2u]]);
    float3 v2 = JPH_Mat44Mul3x3Vec3(param_var_inLHS_2, param_var_inRHS_2);
    JPH_HairPosition_1 root;
    root.mPosition = (((v0 * sp.mU) + (v1 * sp.mV)) + (v2 * ((1.0 - sp.mU) - sp.mV))) + gContext.cScalpToHead[3].xyz;
    float3 tangent = fast::normalize(v1 - v0);
    float3 normal = fast::normalize(cross(tangent, v2 - v0));
    float3 binormal = cross(tangent, normal);
    float3 param_var_inCol0 = normal;
    float3 param_var_inCol1 = binormal;
    float3 param_var_inCol2 = tangent;
    float4 triangle_basis = JPH_QuatFromMat33(param_var_inCol0, param_var_inCol1, param_var_inCol2);
    float4 param_var_inLHS_3 = triangle_basis;
    uint param_var_inValue = sp.mToBishop;
    float4 param_var_inRHS_3 = JPH_QuatDecompress(param_var_inValue);
    root.mRotation = JPH_QuatMulQuat(param_var_inLHS_3, param_var_inRHS_3);
    gPositions._m0[strand_idx] = JPH_HairPosition{ root.mPosition, root.mRotation };
    float4 param_var_inLHS_4 = root.mRotation;
    uint param_var_inValue_1 = gInitialBishops._m0[strand_idx];
    float4 param_var_inRotation = JPH_QuatDecompress(param_var_inValue_1);
    float4 param_var_inRHS_4 = JPH_QuatConjugate(param_var_inRotation);
    JPH_HairGlobalPoseTransform_1 transform;
    transform.mRotation = JPH_QuatMulQuat(param_var_inLHS_4, param_var_inRHS_4);
    float4 param_var_inLHS_5 = transform.mRotation;
    float3 param_var_inRHS_5 = float3(gInitialPositions._m0[strand_idx]);
    transform.mPosition = root.mPosition - JPH_QuatMulVec3(param_var_inLHS_5, param_var_inRHS_5);
    gGlobalPoseTransforms._m0[strand_idx] = JPH_HairGlobalPoseTransform{ transform.mPosition, transform.mRotation };
}

kernel void HairSkinRoots(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_JPH_HairSkinPoint& gSkinPoints [[buffer(1)]], device type_StructuredBuffer_v3float& gScalpVertices [[buffer(2)]], device type_StructuredBuffer_uint& gScalpTriangles [[buffer(3)]], device type_StructuredBuffer_v3float& gInitialPositions [[buffer(4)]], device type_StructuredBuffer_uint& gInitialBishops [[buffer(5)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(6)]], device type_RWStructuredBuffer_JPH_HairGlobalPoseTransform& gGlobalPoseTransforms [[buffer(7)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    uint3 param_var_tid = gl_GlobalInvocationID;
    src_main(param_var_tid, gContext, gSkinPoints, gScalpVertices, gScalpTriangles, gInitialPositions, gInitialBishops, gPositions, gGlobalPoseTransforms);
}

