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

struct type_StructuredBuffer_uint
{
    uint _m0[1];
};

struct type_StructuredBuffer_v3float
{
    packed_float3 _m0[1];
};

struct type_StructuredBuffer_float
{
    float _m0[1];
};

struct JPH_HairMaterial
{
    float4 mWorldTransformInfluence;
    float4 mGlobalPose;
    float4 mSkinGlobalPose;
    float4 mGravityFactor;
    float4 mHairRadius;
    float4 mBendComplianceMultiplier;
    float4 mGridVelocityFactor;
    uint mEnableCollision;
    uint mEnableLRA;
    uint mEnableGrid;
    float mFriction;
    float mExpLinearDampingDeltaTime;
    float mExpAngularDampingDeltaTime;
    float mBendComplianceInvDeltaTimeSq;
    float mStretchComplianceInvDeltaTimeSq;
    float mGridDensityForceFactor;
    float mInertiaMultiplier;
    float mMaxLinearVelocitySq;
    float mMaxAngularVelocitySq;
};

struct type_StructuredBuffer_JPH_HairMaterial
{
    JPH_HairMaterial _m0[1];
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

kernel void HairUpdateStrands(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_uint& gVerticesFixed [[buffer(1)]], device type_StructuredBuffer_uint& gStrandFractions [[buffer(2)]], device type_StructuredBuffer_v3float& gInitialPositions [[buffer(3)]], device type_StructuredBuffer_uint& gOmega0s [[buffer(4)]], device type_StructuredBuffer_float& gInitialLengths [[buffer(5)]], device type_StructuredBuffer_uint& gStrandVertexCounts [[buffer(6)]], device type_StructuredBuffer_uint& gStrandMaterialIndex [[buffer(7)]], device type_StructuredBuffer_JPH_HairMaterial& gMaterials [[buffer(8)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(9)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        if (gl_GlobalInvocationID.x >= gContext.cNumStrands)
        {
            break;
        }
        uint _121 = (gStrandVertexCounts._m0[gl_GlobalInvocationID.x >> 2u] >> (((gl_GlobalInvocationID.x & 3u) << 3u) & 31u)) & 255u;
        uint _129 = (gStrandMaterialIndex._m0[gl_GlobalInvocationID.x >> 2u] >> (((gl_GlobalInvocationID.x & 3u) << 3u) & 31u)) & 255u;
        float _151;
        if ((gVerticesFixed._m0[gl_GlobalInvocationID.x >> 5u] & (1u << (gl_GlobalInvocationID.x & 31u))) != 0u)
        {
            _151 = 0.0;
        }
        else
        {
            _151 = 1.0;
        }
        uint _163 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        float _174;
        if ((gVerticesFixed._m0[_163 >> 5u] & (1u << (_163 & 31u))) != 0u)
        {
            _174 = 0.0;
        }
        else
        {
            _174 = 1.0;
        }
        float _184 = float((gStrandFractions._m0[_163 >> 2u] >> (((_163 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125;
        bool _196;
        if (gMaterials._m0[_129].mEnableLRA != 0u)
        {
            _196 = _174 > 0.0;
        }
        else
        {
            _196 = false;
        }
        float3 _211;
        if (_196)
        {
            float3 _199 = float3(gPositions._m0[_163].mPosition) - float3(gInitialPositions._m0[gl_GlobalInvocationID.x]);
            float _200 = dot(_199, _199);
            float3 _210;
            if (_200 > (gInitialLengths._m0[gl_GlobalInvocationID.x] * gInitialLengths._m0[gl_GlobalInvocationID.x]))
            {
                _210 = float3(gInitialPositions._m0[gl_GlobalInvocationID.x]) + ((_199 * gInitialLengths._m0[gl_GlobalInvocationID.x]) / float3(sqrt(_200)));
            }
            else
            {
                _210 = float3(gPositions._m0[_163].mPosition);
            }
            _211 = _210;
        }
        else
        {
            _211 = float3(gPositions._m0[_163].mPosition);
        }
        float _212 = gInitialLengths._m0[gl_GlobalInvocationID.x] + gInitialLengths._m0[_163];
        float4 _221;
        float3 _229;
        uint _231;
        float3 _233;
        float4 _235;
        _221 = float4(gPositions._m0[_163].mRotation);
        _229 = _211;
        _231 = gl_GlobalInvocationID.x;
        _233 = float3(gPositions._m0[gl_GlobalInvocationID.x].mPosition);
        _235 = float4(gPositions._m0[gl_GlobalInvocationID.x].mRotation);
        float _215;
        float4 _222;
        float _224;
        float _226;
        uint _228;
        uint _232;
        float _223;
        float3 _230;
        float3 _234;
        float4 _236;
        float _214 = _184;
        float _217 = _151;
        float _218 = _174;
        float _219 = gInitialLengths._m0[gl_GlobalInvocationID.x];
        float _220 = gInitialLengths._m0[_163];
        float _225 = _212;
        uint _227 = _163;
        uint _237 = 2u;
        for (; _237 < _121; _214 = _215, _217 = _218, _219 = _220, _221 = _222, _218 = _223, _220 = _224, _225 = _226, _227 = _228, _229 = _230, _231 = _232, _233 = _234, _235 = _236, _237++)
        {
            float3 _258 = float3(float(int(gOmega0s._m0[_227] & 511u) - 255), float(int((gOmega0s._m0[_227] >> 9u) & 511u) - 255), float((gOmega0s._m0[_227] >> 18u) & 511u) - 255.0) * 0.0027729677967727184295654296875;
            float4 _266 = float4(_258, sqrt(precise::max(1.0 - dot(_258, _258), 0.0)));
            float4 _272;
            if ((gOmega0s._m0[_227] & 2147483648u) != 0u)
            {
                _272 = -_266;
            }
            else
            {
                _272 = _266;
            }
            uint _274 = (gOmega0s._m0[_227] >> 29u) & 3u;
            float4 _292;
            if (_274 == 0u)
            {
                _292 = _272.wxyz;
            }
            else
            {
                float4 _291;
                if (_274 == 1u)
                {
                    _291 = _272.xwyz;
                }
                else
                {
                    float4 _290;
                    if (_274 == 2u)
                    {
                        _290 = _272.xywz;
                    }
                    else
                    {
                        _290 = _272;
                    }
                    _291 = _290;
                }
                _292 = _291;
            }
            _228 = _227 + gContext.cNumStrands;
            if ((gVerticesFixed._m0[_228 >> 5u] & (1u << (_228 & 31u))) != 0u)
            {
                _223 = 0.0;
            }
            else
            {
                _223 = 1.0;
            }
            _215 = float((gStrandFractions._m0[_228 >> 2u] >> (((_228 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125;
            _224 = gInitialLengths._m0[_228];
            _222 = float4(gPositions._m0[_228].mRotation);
            bool _323;
            if (gMaterials._m0[_129].mEnableLRA != 0u)
            {
                _323 = _223 > 0.0;
            }
            else
            {
                _323 = false;
            }
            float3 _338;
            if (_323)
            {
                float3 _326 = float3(gPositions._m0[_228].mPosition) - float3(gInitialPositions._m0[gl_GlobalInvocationID.x]);
                float _327 = dot(_326, _326);
                float3 _337;
                if (_327 > (_225 * _225))
                {
                    _337 = float3(gInitialPositions._m0[gl_GlobalInvocationID.x]) + ((_326 * _225) / float3(sqrt(_327)));
                }
                else
                {
                    _337 = float3(gPositions._m0[_228].mPosition);
                }
                _338 = _337;
            }
            else
            {
                _338 = float3(gPositions._m0[_228].mPosition);
            }
            _226 = _225 + _224;
            float _340 = precise::min(_218, _223) / gMaterials._m0[_129].mInertiaMultiplier;
            float _344 = ((_218 + _223) + (4.0 * _340)) + gMaterials._m0[_129].mStretchComplianceInvDeltaTimeSq;
            float4 _467;
            float3 _468;
            if (_344 >= 9.9999999600419720025001879548654e-13)
            {
                float4 _101 = _221;
                float4 _102 = _221;
                float3 _375 = ((_338 - _229) - ((((_221.xyz * (_102.z + _102.z)) + (float3(_102.y, -_102.x, _102.w) * (_102.w + _102.w))) - float3(0.0, 0.0, 1.0)) * _220)) / float3(_344);
                float3 _103 = _375;
                float4 _104 = float4(-_101.y, _101.x, -_101.w, _101.z);
                float4 _464 = float4(((_103.x * _104.w) + (_103.y * _104.z)) - (_103.z * _104.y), (((-_103.x) * _104.z) + (_103.y * _104.w)) + (_103.z * _104.x), ((_103.x * _104.y) - (_103.y * _104.x)) + (_103.z * _104.w), (((-_103.x) * _104.x) - (_103.y * _104.y)) - (_103.z * _104.z)) * ((2.0 * _340) / _220);
                float4 _465 = _221 + _464;
                _101 = _465;
                _230 = _338 - (_375 * _223);
                _467 = fast::normalize(_465);
                _468 = _229 + (_375 * _218);
            }
            else
            {
                _230 = _338;
                _467 = _221;
                _468 = _229;
            }
            float _470 = precise::min(_217, _218) / gMaterials._m0[_129].mInertiaMultiplier;
            float _474 = ((_217 + _218) + (4.0 * _470)) + gMaterials._m0[_129].mStretchComplianceInvDeltaTimeSq;
            float3 _597;
            float4 _598;
            if (_474 >= 9.9999999600419720025001879548654e-13)
            {
                float4 _97 = _235;
                float4 _98 = _235;
                float3 _505 = ((_468 - _233) - ((((_235.xyz * (_98.z + _98.z)) + (float3(_98.y, -_98.x, _98.w) * (_98.w + _98.w))) - float3(0.0, 0.0, 1.0)) * _219)) / float3(_474);
                float3 _99 = _505;
                float4 _100 = float4(-_97.y, _97.x, -_97.w, _97.z);
                float4 _594 = float4(((_99.x * _100.w) + (_99.y * _100.z)) - (_99.z * _100.y), (((-_99.x) * _100.z) + (_99.y * _100.w)) + (_99.z * _100.x), ((_99.x * _100.y) - (_99.y * _100.x)) + (_99.z * _100.w), (((-_99.x) * _100.x) - (_99.y * _100.y)) - (_99.z * _100.z)) * ((2.0 * _470) / _219);
                float4 _595 = _235 + _594;
                _97 = _595;
                _234 = _468 - (_505 * _218);
                _597 = _233 + (_505 * _217);
                _598 = fast::normalize(_595);
            }
            else
            {
                _234 = _468;
                _597 = _233;
                _598 = _235;
            }
            float4 _88 = gMaterials._m0[_129].mBendComplianceMultiplier;
            float _602 = precise::min(_217, _218) / (gMaterials._m0[_129].mInertiaMultiplier * (_219 * _219));
            float _606 = precise::min(_218, _223) / (gMaterials._m0[_129].mInertiaMultiplier * (_220 * _220));
            float _607 = _214 * 3.0;
            uint _608 = uint(_607);
            float _610 = _607 - float(_608);
            float _622 = (_602 + _606) + (gMaterials._m0[_129].mBendComplianceInvDeltaTimeSq * ((_88[_608] * (1.0 - _610)) + (_88[_608 + 1u] * _610)));
            float4 _936;
            if (_622 >= 9.9999999600419720025001879548654e-13)
            {
                float4 _89 = _598;
                float4 _90 = float4(-_89.x, -_89.y, -_89.z, _89.w);
                float4 _91 = _467;
                float4 _730 = float4((((_90.w * _91.x) + (_90.x * _91.w)) + (_90.y * _91.z)) - (_90.z * _91.y), (((_90.w * _91.y) - (_90.x * _91.z)) + (_90.y * _91.w)) + (_90.z * _91.x), (((_90.w * _91.z) + (_90.x * _91.y)) - (_90.y * _91.x)) + (_90.z * _91.w), (((_90.w * _91.w) - (_90.x * _91.x)) - (_90.y * _91.y)) - (_90.z * _91.z));
                float4 _731 = _730 - _292;
                float4 _732 = _730 + _292;
                float4 _739;
                if (dot(_732, _732) < dot(_731, _731))
                {
                    _739 = _732;
                }
                else
                {
                    _739 = _731;
                }
                float4 _92 = _739 / float4(_622);
                _92.w = 0.0;
                float4 _93 = _598;
                float4 _94 = _92;
                float4 _837 = float4((((_93.w * _94.x) + (_93.x * _94.w)) + (_93.y * _94.z)) - (_93.z * _94.y), (((_93.w * _94.y) - (_93.x * _94.z)) + (_93.y * _94.w)) + (_93.z * _94.x), (((_93.w * _94.z) + (_93.x * _94.y)) - (_93.y * _94.x)) + (_93.z * _94.w), (((_93.w * _94.w) - (_93.x * _94.x)) - (_93.y * _94.y)) - (_93.z * _94.z)) * _606;
                float4 _95 = _467;
                float4 _96 = _92;
                float4 _931 = float4((((_95.w * _96.x) + (_95.x * _96.w)) + (_95.y * _96.z)) - (_95.z * _96.y), (((_95.w * _96.y) - (_95.x * _96.z)) + (_95.y * _96.w)) + (_95.z * _96.x), (((_95.w * _96.z) + (_95.x * _96.y)) - (_95.y * _96.x)) + (_95.z * _96.w), (((_95.w * _96.w) - (_95.x * _96.x)) - (_95.y * _96.y)) - (_95.z * _96.z)) * _602;
                _236 = fast::normalize(_467 - _837);
                _936 = fast::normalize(_598 + _931);
            }
            else
            {
                _236 = _467;
                _936 = _598;
            }
            gPositions._m0[_231] = JPH_HairPosition{ _597, _936 };
            _232 = _231 + gContext.cNumStrands;
        }
        gPositions._m0[_231] = JPH_HairPosition{ _233, _235 };
        gPositions._m0[_231 + gContext.cNumStrands] = JPH_HairPosition{ _229, _235 };
        break;
    } while(false);
}

