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

kernel void HairCalculateCollisionPlanes(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_JPH_HairPosition& gPositions [[buffer(1)]], device type_StructuredBuffer_v4float& gShapePlanes [[buffer(2)]], device type_StructuredBuffer_v3float& gShapeVertices [[buffer(3)]], device type_StructuredBuffer_uint& gShapeIndices [[buffer(4)]], device type_RWStructuredBuffer_JPH_HairCollisionPlane& gCollisionPlanes [[buffer(5)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        uint _65 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_65 >= gContext.cNumVertices)
        {
            break;
        }
        float4 _81;
        uint _83;
        _81 = float4(1.0, 0.0, 0.0, 1000000.0);
        _83 = 0u;
        float _78;
        uint _84;
        uint _80;
        float4 _82;
        uint _86;
        uint _74 = 0u;
        float _77 = -1000000.0;
        uint _79 = 0u;
        uint _85 = 0u;
        for (;;)
        {
            if (gShapeIndices._m0[_79] == 0u)
            {
                break;
            }
            uint _100;
            float _102;
            float3 _104;
            _80 = _79 + 1u;
            _86 = _85;
            _100 = 0u;
            _102 = -1000000.0;
            _104 = float3(0.0);
            for (uint _106 = 0u; _106 < gShapeIndices._m0[_79]; )
            {
                float _115 = dot(float3(gPositions._m0[_65].mPosition), gShapePlanes._m0[_86].xyz) + gShapePlanes._m0[_86].w;
                bool _116 = _115 > _102;
                uint _101 = _116 ? _80 : _100;
                _80 += 2u;
                _86++;
                _100 = _101;
                _102 = _116 ? _115 : _102;
                _104 = select(_104, gShapePlanes._m0[_86].xyz, bool3(_116));
                _106++;
                continue;
            }
            float3 _119 = _104 * (-_102);
            bool _120 = _102 > 0.0;
            float3 _168;
            if (_120)
            {
                uint _125 = _100 + 1u;
                float3 _137;
                float3 _139;
                _137 = float3(gShapeVertices._m0[gShapeIndices._m0[gShapeIndices._m0[_125] - 1u]]);
                _139 = _119;
                float3 _138;
                float _135;
                float3 _140;
                float _134 = 999999995904.0;
                uint _141 = gShapeIndices._m0[_100];
                for (; _141 < gShapeIndices._m0[_125]; _134 = _135, _137 = _138, _139 = _140, _141++)
                {
                    _138 = float3(gShapeVertices._m0[gShapeIndices._m0[_141]]);
                    float3 _149 = _138 - _137;
                    float3 _150 = _137 - float3(gPositions._m0[_65].mPosition);
                    if (dot(cross(_149, _104), _150) <= 0.0)
                    {
                        float3 _162 = _150 + (_149 * fast::clamp((-dot(_150, _149)) / dot(_149, _149), 0.0, 1.0));
                        float _163 = dot(_162, _162);
                        bool _164 = _163 < _134;
                        _135 = _164 ? _163 : _134;
                        _140 = select(_139, _162, bool3(_164));
                    }
                    else
                    {
                        _135 = _134;
                        _140 = _139;
                    }
                }
                _168 = _139;
            }
            else
            {
                _168 = _119;
            }
            float3 _169 = -_168;
            float _170 = length(_169);
            float _175;
            if (_120)
            {
                _175 = -_170;
            }
            else
            {
                _175 = _170;
            }
            bool _178 = _175 > _77;
            if (_178)
            {
                float3 _187;
                if (_170 > 0.0)
                {
                    _187 = select(_168, _169, bool3(_120)) / float3(_170);
                }
                else
                {
                    _187 = _104;
                }
                _82 = float4(_187, -dot(_187, float3(gPositions._m0[_65].mPosition) + _168));
            }
            else
            {
                _82 = _81;
            }
            _78 = _178 ? _175 : _77;
            _84 = _178 ? _74 : _83;
            _74++;
            _77 = _78;
            _79 = _80;
            _81 = _82;
            _83 = _84;
            _85 = _86;
            continue;
        }
        gCollisionPlanes._m0[_65] = JPH_HairCollisionPlane{ _81, _83 };
        break;
    } while(false);
}

