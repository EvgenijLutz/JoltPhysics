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

kernel void HairSkinRoots(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_JPH_HairSkinPoint& gSkinPoints [[buffer(1)]], device type_StructuredBuffer_v3float& gScalpVertices [[buffer(2)]], device type_StructuredBuffer_uint& gScalpTriangles [[buffer(3)]], device type_StructuredBuffer_v3float& gInitialPositions [[buffer(4)]], device type_StructuredBuffer_uint& gInitialBishops [[buffer(5)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(6)]], device type_RWStructuredBuffer_JPH_HairGlobalPoseTransform& gGlobalPoseTransforms [[buffer(7)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        if (gl_GlobalInvocationID.x >= gContext.cNumStrands)
        {
            break;
        }
        float _86 = gSkinPoints._m0[gl_GlobalInvocationID.x].mU;
        float _88 = gSkinPoints._m0[gl_GlobalInvocationID.x].mV;
        uint _91 = gSkinPoints._m0[gl_GlobalInvocationID.x].mTriangleIndex * 3u;
        float3 _113 = ((gContext.cScalpToHead[0u].xyz * gScalpVertices._m0[gScalpTriangles._m0[_91]][0]) + (gContext.cScalpToHead[1u].xyz * gScalpVertices._m0[gScalpTriangles._m0[_91]][1])) + (gContext.cScalpToHead[2u].xyz * gScalpVertices._m0[gScalpTriangles._m0[_91]][2]);
        uint _114 = _91 + 1u;
        float3 _126 = ((gContext.cScalpToHead[0u].xyz * gScalpVertices._m0[gScalpTriangles._m0[_114]][0]) + (gContext.cScalpToHead[1u].xyz * gScalpVertices._m0[gScalpTriangles._m0[_114]][1])) + (gContext.cScalpToHead[2u].xyz * gScalpVertices._m0[gScalpTriangles._m0[_114]][2]);
        uint _127 = _91 + 2u;
        float3 _139 = ((gContext.cScalpToHead[0u].xyz * gScalpVertices._m0[gScalpTriangles._m0[_127]][0]) + (gContext.cScalpToHead[1u].xyz * gScalpVertices._m0[gScalpTriangles._m0[_127]][1])) + (gContext.cScalpToHead[2u].xyz * gScalpVertices._m0[gScalpTriangles._m0[_127]][2]);
        float3 _150 = (((_113 * _86) + (_126 * _88)) + (_139 * ((1.0 - _86) - _88))) + gContext.cScalpToHead[3].xyz;
        float3 _152 = fast::normalize(_126 - _113);
        float3 _155 = fast::normalize(cross(_152, _139 - _113));
        float3 _156 = cross(_152, _155);
        float4 _253;
        do
        {
            float _159 = _155.x;
            float _160 = _156.y;
            float _161 = _159 + _160;
            float _162 = _152.z;
            float _163 = _161 + _162;
            if (_163 >= 0.0)
            {
                float _237 = sqrt(_163 + 1.0);
                float _238 = 0.5 / _237;
                _253 = float4((_156.z - _152.y) * _238, (_152.x - _155.z) * _238, (_155.y - _156.x) * _238, 0.5 * _237);
                break;
            }
            else
            {
                bool _172;
                if (_159 > _160)
                {
                    _172 = _159 > _162;
                }
                else
                {
                    _172 = false;
                }
                if (_172)
                {
                    float _220 = sqrt((_159 - (_160 + _162)) + 1.0);
                    float _221 = 0.5 / _220;
                    _253 = float4(0.5 * _220, (_156.x + _155.y) * _221, (_155.z + _152.x) * _221, (_156.z - _152.y) * _221);
                    break;
                }
                else
                {
                    if (_160 > _162)
                    {
                        float _201 = sqrt((_160 - (_162 + _159)) + 1.0);
                        float _202 = 0.5 / _201;
                        _253 = float4((_156.x + _155.y) * _202, 0.5 * _201, (_152.y + _156.z) * _202, (_152.x - _155.z) * _202);
                        break;
                    }
                    else
                    {
                        float _182 = sqrt((_162 - _161) + 1.0);
                        float _183 = 0.5 / _182;
                        _253 = float4((_155.z + _152.x) * _183, (_152.y + _156.z) * _183, 0.5 * _182, (_155.y - _156.x) * _183);
                        break;
                    }
                    break; // unreachable workaround
                }
                break; // unreachable workaround
            }
            break; // unreachable workaround
        } while(false);
        float3 _268 = float3(float(int(gSkinPoints._m0[gl_GlobalInvocationID.x].mToBishop & 511u) - 255), float(int((gSkinPoints._m0[gl_GlobalInvocationID.x].mToBishop >> 9u) & 511u) - 255), float((gSkinPoints._m0[gl_GlobalInvocationID.x].mToBishop >> 18u) & 511u) - 255.0) * 0.0027729677967727184295654296875;
        float4 _276 = float4(_268, sqrt(precise::max(1.0 - dot(_268, _268), 0.0)));
        float4 _282;
        if ((gSkinPoints._m0[gl_GlobalInvocationID.x].mToBishop & 2147483648u) != 0u)
        {
            _282 = -_276;
        }
        else
        {
            _282 = _276;
        }
        uint _284 = (gSkinPoints._m0[gl_GlobalInvocationID.x].mToBishop >> 29u) & 3u;
        float4 _302;
        if (_284 == 0u)
        {
            _302 = _282.wxyz;
        }
        else
        {
            float4 _300;
            if (_284 == 1u)
            {
                _300 = _282.xwyz;
            }
            else
            {
                float4 _298;
                if (_284 == 2u)
                {
                    _298 = _282.xywz;
                }
                else
                {
                    _298 = _282;
                }
                _300 = _298;
            }
            _302 = _300;
        }
        float _317 = (((_253.w * _302.x) + (_253.x * _302.w)) + (_253.y * _302.z)) - (_253.z * _302.y);
        float _324 = (((_253.w * _302.y) - (_253.x * _302.z)) + (_253.y * _302.w)) + (_253.z * _302.x);
        float _331 = (((_253.w * _302.z) + (_253.x * _302.y)) - (_253.y * _302.x)) + (_253.z * _302.w);
        float _338 = (((_253.w * _302.w) - (_253.x * _302.x)) - (_253.y * _302.y)) - (_253.z * _302.z);
        gPositions._m0[gl_GlobalInvocationID.x] = JPH_HairPosition{ _150, float4(_317, _324, _331, _338) };
        float3 _358 = float3(float(int(gInitialBishops._m0[gl_GlobalInvocationID.x] & 511u) - 255), float(int((gInitialBishops._m0[gl_GlobalInvocationID.x] >> 9u) & 511u) - 255), float((gInitialBishops._m0[gl_GlobalInvocationID.x] >> 18u) & 511u) - 255.0) * 0.0027729677967727184295654296875;
        float4 _366 = float4(_358, sqrt(precise::max(1.0 - dot(_358, _358), 0.0)));
        float4 _372;
        if ((gInitialBishops._m0[gl_GlobalInvocationID.x] & 2147483648u) != 0u)
        {
            _372 = -_366;
        }
        else
        {
            _372 = _366;
        }
        uint _374 = (gInitialBishops._m0[gl_GlobalInvocationID.x] >> 29u) & 3u;
        float4 _392;
        if (_374 == 0u)
        {
            _392 = _372.wxyz;
        }
        else
        {
            float4 _390;
            if (_374 == 1u)
            {
                _390 = _372.xwyz;
            }
            else
            {
                float4 _388;
                if (_374 == 2u)
                {
                    _388 = _372.xywz;
                }
                else
                {
                    _388 = _372;
                }
                _390 = _388;
            }
            _392 = _390;
        }
        float _394 = -_392.x;
        float _396 = -_392.y;
        float _398 = -_392.z;
        float _427 = (((_338 * _392.w) - (_317 * _394)) - (_324 * _396)) - (_331 * _398);
        float4 _428 = float4((((_338 * _394) + (_317 * _392.w)) + (_324 * _398)) - (_331 * _396), (((_338 * _396) - (_317 * _398)) + (_324 * _392.w)) + (_331 * _394), (((_338 * _398) + (_317 * _396)) - (_324 * _394)) + (_331 * _392.w), _427);
        float3 _436 = (float3(gInitialPositions._m0[gl_GlobalInvocationID.x][1], gInitialPositions._m0[gl_GlobalInvocationID.x][2], gInitialPositions._m0[gl_GlobalInvocationID.x][0]) * _428.xyz) - (_428.yzx * float3(gInitialPositions._m0[gl_GlobalInvocationID.x]));
        float3 _437 = _436.yzx;
        float3 _444 = (_437 * _427) + ((_436.zxy * _428.xyz) - (_428.yzx * _437)).yzx;
        gGlobalPoseTransforms._m0[gl_GlobalInvocationID.x] = JPH_HairGlobalPoseTransform{ _150 - (float3(gInitialPositions._m0[gl_GlobalInvocationID.x]) + (_444 + _444)), _428 };
        break;
    } while(false);
}

