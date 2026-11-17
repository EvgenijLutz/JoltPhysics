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

struct JPH_HairPosition
{
    packed_float3 mPosition;
    packed_float4 mRotation;
};

struct type_StructuredBuffer_JPH_HairPosition
{
    JPH_HairPosition _m0[1];
};

struct type_StructuredBuffer_v4float
{
    float4 _m0[1];
};

struct type_StructuredBuffer_v3float
{
    packed_float3 _m0[1];
};

struct type_StructuredBuffer_uint
{
    uint _m0[1];
};

struct JPH_HairCollisionPlane
{
    packed_float4 mPlane;
    uint mShapeIndex;
};

struct type_RWStructuredBuffer_JPH_HairCollisionPlane
{
    JPH_HairCollisionPlane _m0[1];
};

struct JPH_HairCollisionPlane_1
{
    float4 mPlane;
    uint mShapeIndex;
};

static inline __attribute__((always_inline))
float JPH_PlaneSignedDistance(thread const float4& inPlane, thread const float3& inPoint)
{
    return dot(inPoint, inPlane.xyz) + inPlane.w;
}

static inline __attribute__((always_inline))
float3 JPH_PlaneGetNormal(thread const float4& inPlane)
{
    return inPlane.xyz;
}

static inline __attribute__((always_inline))
float3 JPH_GetClosestPointOnLine(thread const float3& inA, thread const float3& inAB)
{
    float v = fast::clamp((-dot(inA, inAB)) / dot(inAB, inAB), 0.0, 1.0);
    return inA + (inAB * v);
}

static inline __attribute__((always_inline))
float4 JPH_PlaneFromPointAndNormal(thread const float3& inPoint, thread const float3& inNormal)
{
    return float4(inNormal, -dot(inNormal, inPoint));
}

static inline __attribute__((always_inline))
void src_main(thread const uint3& tid, constant type_gContext& gContext, device type_StructuredBuffer_JPH_HairPosition& gPositions, device type_StructuredBuffer_v4float& gShapePlanes, device type_StructuredBuffer_v3float& gShapeVertices, device type_StructuredBuffer_uint& gShapeIndices, device type_RWStructuredBuffer_JPH_HairCollisionPlane& gCollisionPlanes)
{
    uint vtx = tid.x + gContext.cNumStrands;
    if (vtx >= gContext.cNumVertices)
    {
        return;
    }
    float3 pos = float3(gPositions._m0[vtx].mPosition);
    JPH_HairCollisionPlane_1 collision_plane;
    collision_plane.mPlane = float4(1.0, 0.0, 0.0, 1000000.0);
    collision_plane.mShapeIndex = 0u;
    float largest_penetration = -1000000.0;
    uint current_idx = 0u;
    uint current_plane = 0u;
    float3 temp_var_ternary;
    for (uint current_shape_idx = 0u; true; current_shape_idx++)
    {
        float max_distance = -1000000.0;
        float3 max_plane_normal = float3(0.0);
        uint max_plane_face_info = 0u;
        uint _138 = current_idx;
        current_idx = _138 + 1u;
        uint nf = gShapeIndices._m0[_138];
        if (nf == 0u)
        {
            break;
        }
        for (uint f = 0u; f < nf; f++)
        {
            uint _153 = current_plane;
            current_plane = _153 + 1u;
            float4 plane = gShapePlanes._m0[_153];
            float4 param_var_inPlane = plane;
            float3 param_var_inPoint = pos;
            float _distance = JPH_PlaneSignedDistance(param_var_inPlane, param_var_inPoint);
            if (_distance > max_distance)
            {
                max_distance = _distance;
                float4 param_var_inPlane_1 = plane;
                max_plane_normal = JPH_PlaneGetNormal(param_var_inPlane_1);
                max_plane_face_info = current_idx;
            }
            current_idx += 2u;
        }
        float3 closest_point = max_plane_normal * (-max_distance);
        bool is_outside = max_distance > 0.0;
        if (is_outside)
        {
            float closest_point_dist_sq = 999999995904.0;
            uint vi_end = gShapeIndices._m0[max_plane_face_info + 1u];
            float3 p1 = float3(gShapeVertices._m0[gShapeIndices._m0[vi_end - 1u]]);
            for (uint vi = gShapeIndices._m0[max_plane_face_info]; vi < vi_end; vi++)
            {
                float3 p2 = float3(gShapeVertices._m0[gShapeIndices._m0[vi]]);
                float3 p1_p2 = p2 - p1;
                float3 p1_pos = p1 - pos;
                float3 edge_normal = cross(p1_p2, max_plane_normal);
                if (dot(edge_normal, p1_pos) <= 0.0)
                {
                    float3 param_var_inA = p1_pos;
                    float3 param_var_inAB = p1_p2;
                    float3 closest = JPH_GetClosestPointOnLine(param_var_inA, param_var_inAB);
                    float distance_sq = dot(closest, closest);
                    if (distance_sq < closest_point_dist_sq)
                    {
                        closest_point_dist_sq = distance_sq;
                        closest_point = closest;
                    }
                }
                p1 = p2;
            }
        }
        float3 normal = -closest_point;
        float normal_length = length(normal);
        float penetration = normal_length;
        if (is_outside)
        {
            penetration = -penetration;
        }
        else
        {
            normal = -normal;
        }
        if (penetration > largest_penetration)
        {
            if (normal_length > 0.0)
            {
                temp_var_ternary = normal / float3(normal_length);
            }
            else
            {
                temp_var_ternary = max_plane_normal;
            }
            normal = temp_var_ternary;
            float3 param_var_inPoint_1 = pos + closest_point;
            float3 param_var_inNormal = normal;
            collision_plane.mPlane = JPH_PlaneFromPointAndNormal(param_var_inPoint_1, param_var_inNormal);
            collision_plane.mShapeIndex = current_shape_idx;
            largest_penetration = penetration;
        }
    }
    gCollisionPlanes._m0[vtx] = JPH_HairCollisionPlane{ collision_plane.mPlane, collision_plane.mShapeIndex };
}

kernel void HairCalculateCollisionPlanes(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_JPH_HairPosition& gPositions [[buffer(1)]], device type_StructuredBuffer_v4float& gShapePlanes [[buffer(2)]], device type_StructuredBuffer_v3float& gShapeVertices [[buffer(3)]], device type_StructuredBuffer_uint& gShapeIndices [[buffer(4)]], device type_RWStructuredBuffer_JPH_HairCollisionPlane& gCollisionPlanes [[buffer(5)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    uint3 param_var_tid = gl_GlobalInvocationID;
    src_main(param_var_tid, gContext, gPositions, gShapePlanes, gShapeVertices, gShapeIndices, gCollisionPlanes);
}

