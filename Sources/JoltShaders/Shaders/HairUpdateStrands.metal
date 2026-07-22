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
        uint _95 = gl_GlobalInvocationID.x >> 2u;
        uint _100 = ((gl_GlobalInvocationID.x & 3u) << 3u) & 31u;
        uint _102 = (gStrandVertexCounts._m0[_95] >> _100) & 255u;
        uint _106 = (gStrandMaterialIndex._m0[_95] >> _100) & 255u;
        float _124 = ((gVerticesFixed._m0[gl_GlobalInvocationID.x >> 5u] & (1u << (gl_GlobalInvocationID.x & 31u))) != 0u) ? 0.0 : 1.0;
        uint _133 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        uint _139 = gVerticesFixed._m0[_133 >> 5u] & (1u << (_133 & 31u));
        float _141 = (_139 != 0u) ? 0.0 : 1.0;
        float _151 = float((gStrandFractions._m0[_133 >> 2u] >> (((_133 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125;
        bool _158 = gMaterials._m0[_106].mEnableLRA != 0u;
        bool _164;
        if (_158)
        {
            bool _161 = false;
            bool _162 = true;
            _164 = _139 == 0u;
        }
        else
        {
            _164 = false;
        }
        float3 _179;
        if (_164)
        {
            float3 _167 = float3(gPositions._m0[_133].mPosition) - float3(gInitialPositions._m0[gl_GlobalInvocationID.x]);
            float _168 = dot(_167, _167);
            float3 _178;
            if (_168 > (gInitialLengths._m0[gl_GlobalInvocationID.x] * gInitialLengths._m0[gl_GlobalInvocationID.x]))
            {
                _178 = float3(gInitialPositions._m0[gl_GlobalInvocationID.x]) + ((_167 * gInitialLengths._m0[gl_GlobalInvocationID.x]) / float3(sqrt(_168)));
            }
            else
            {
                _178 = float3(gPositions._m0[_133].mPosition);
            }
            _179 = _178;
        }
        else
        {
            _179 = float3(gPositions._m0[_133].mPosition);
        }
        float _180 = gInitialLengths._m0[gl_GlobalInvocationID.x] + gInitialLengths._m0[_133];
        float4 _189;
        float3 _197;
        uint _199;
        float3 _201;
        float4 _203;
        _189 = float4(gPositions._m0[_133].mRotation);
        _197 = _179;
        _199 = gl_GlobalInvocationID.x;
        _201 = float3(gPositions._m0[gl_GlobalInvocationID.x].mPosition);
        _203 = float4(gPositions._m0[gl_GlobalInvocationID.x].mRotation);
        float _183;
        float4 _190;
        float _191;
        float _192;
        float _194;
        uint _196;
        uint _200;
        float3 _198;
        float3 _202;
        float4 _204;
        float _182 = _151;
        float _185 = _124;
        float _186 = _141;
        float _187 = gInitialLengths._m0[gl_GlobalInvocationID.x];
        float _188 = gInitialLengths._m0[_133];
        float _193 = _180;
        uint _195 = _133;
        uint _205 = 2u;
        for (; _205 < _102; _182 = _183, _185 = _186, _187 = _188, _189 = _190, _186 = _191, _188 = _192, _193 = _194, _195 = _196, _197 = _198, _199 = _200, _201 = _202, _203 = _204, _205++)
        {
            float3 _226 = float3(float(int(gOmega0s._m0[_195] & 511u) - 255), float(int((gOmega0s._m0[_195] >> 9u) & 511u) - 255), float((gOmega0s._m0[_195] >> 18u) & 511u) - 255.0) * 0.0027729677967727184295654296875;
            float4 _234 = float4(_226, sqrt(precise::max(1.0 - dot(_226, _226), 0.0)));
            float4 _240;
            if ((gOmega0s._m0[_195] & 2147483648u) != 0u)
            {
                _240 = -_234;
            }
            else
            {
                _240 = _234;
            }
            uint _242 = (gOmega0s._m0[_195] >> 29u) & 3u;
            float4 _260;
            if (_242 == 0u)
            {
                _260 = _240.wxyz;
            }
            else
            {
                float4 _259;
                if (_242 == 1u)
                {
                    _259 = _240.xwyz;
                }
                else
                {
                    float4 _258;
                    if (_242 == 2u)
                    {
                        _258 = _240.xywz;
                    }
                    else
                    {
                        _258 = _240;
                    }
                    _259 = _258;
                }
                _260 = _259;
            }
            _196 = _195 + gContext.cNumStrands;
            uint _266 = gVerticesFixed._m0[_196 >> 5u] & (1u << (_196 & 31u));
            _191 = (_266 != 0u) ? 0.0 : 1.0;
            _183 = float((gStrandFractions._m0[_196 >> 2u] >> (((_196 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125;
            _192 = gInitialLengths._m0[_196];
            _190 = float4(gPositions._m0[_196].mRotation);
            bool _286;
            if (_158)
            {
                bool _283 = false;
                bool _284 = true;
                _286 = _266 == 0u;
            }
            else
            {
                _286 = false;
            }
            float3 _301;
            if (_286)
            {
                float3 _289 = float3(gPositions._m0[_196].mPosition) - float3(gInitialPositions._m0[gl_GlobalInvocationID.x]);
                float _290 = dot(_289, _289);
                float3 _300;
                if (_290 > (_193 * _193))
                {
                    _300 = float3(gInitialPositions._m0[gl_GlobalInvocationID.x]) + ((_289 * _193) / float3(sqrt(_290)));
                }
                else
                {
                    _300 = float3(gPositions._m0[_196].mPosition);
                }
                _301 = _300;
            }
            else
            {
                _301 = float3(gPositions._m0[_196].mPosition);
            }
            _194 = _193 + _192;
            float _302 = precise::min(_186, _191);
            float _303 = _302 / gMaterials._m0[_106].mInertiaMultiplier;
            float _307 = ((_186 + _191) + (4.0 * _303)) + gMaterials._m0[_106].mStretchComplianceInvDeltaTimeSq;
            float4 _364;
            float3 _365;
            if (_307 >= 9.9999999600419720025001879548654e-13)
            {
                float3 _328 = ((_301 - _197) - ((((_189.xyz * (_189.z + _189.z)) + (float3(_189.y, -_189.x, _189.w) * (_189.w + _189.w))) - float3(0.0, 0.0, 1.0)) * _188)) / float3(_307);
                float _333 = -_189.y;
                float _334 = -_189.w;
                float _335 = _328.x;
                float _337 = _328.y;
                float _340 = _328.z;
                _198 = _301 - (_328 * _191);
                _364 = fast::normalize(_189 + (float4(((_335 * _189.z) + (_337 * _334)) - (_340 * _189.x), ((_335 * _189.w) + (_337 * _189.z)) + (_340 * _333), ((_335 * _189.x) - (_337 * _333)) + (_340 * _189.z), ((_335 * _189.y) - (_337 * _189.x)) - (_340 * _334)) * ((2.0 * _303) / _188)));
                _365 = _197 + (_328 * _186);
            }
            else
            {
                _198 = _301;
                _364 = _189;
                _365 = _197;
            }
            float _366 = precise::min(_185, _186);
            float _367 = _366 / gMaterials._m0[_106].mInertiaMultiplier;
            float _371 = ((_185 + _186) + (4.0 * _367)) + gMaterials._m0[_106].mStretchComplianceInvDeltaTimeSq;
            float3 _428;
            float4 _429;
            if (_371 >= 9.9999999600419720025001879548654e-13)
            {
                float3 _392 = ((_365 - _201) - ((((_203.xyz * (_203.z + _203.z)) + (float3(_203.y, -_203.x, _203.w) * (_203.w + _203.w))) - float3(0.0, 0.0, 1.0)) * _187)) / float3(_371);
                float _397 = -_203.y;
                float _398 = -_203.w;
                float _399 = _392.x;
                float _401 = _392.y;
                float _404 = _392.z;
                _202 = _365 - (_392 * _186);
                _428 = _201 + (_392 * _185);
                _429 = fast::normalize(_203 + (float4(((_399 * _203.z) + (_401 * _398)) - (_404 * _203.x), ((_399 * _203.w) + (_401 * _203.z)) + (_404 * _397), ((_399 * _203.x) - (_401 * _397)) + (_404 * _203.z), ((_399 * _203.y) - (_401 * _203.x)) - (_404 * _398)) * ((2.0 * _367) / _187)));
            }
            else
            {
                _202 = _365;
                _428 = _201;
                _429 = _203;
            }
            float4 _85 = gMaterials._m0[_106].mBendComplianceMultiplier;
            float _432 = _366 / (gMaterials._m0[_106].mInertiaMultiplier * (_187 * _187));
            float _435 = _302 / (gMaterials._m0[_106].mInertiaMultiplier * (_188 * _188));
            float _436 = _182 * 3.0;
            uint _437 = uint(_436);
            float _439 = _436 - float(_437);
            float _451 = (_432 + _435) + (gMaterials._m0[_106].mBendComplianceInvDeltaTimeSq * ((_85[_437] * (1.0 - _439)) + (_85[_437 + 1u] * _439)));
            float4 _557;
            if (_451 >= 9.9999999600419720025001879548654e-13)
            {
                float _456 = -_429.x;
                float _458 = -_429.y;
                float _460 = -_429.z;
                float4 _494 = float4((((_429.w * _364.x) + (_456 * _364.w)) + (_458 * _364.z)) - (_460 * _364.y), (((_429.w * _364.y) - (_456 * _364.z)) + (_458 * _364.w)) + (_460 * _364.x), (((_429.w * _364.z) + (_456 * _364.y)) - (_458 * _364.x)) + (_460 * _364.w), (((_429.w * _364.w) - (_456 * _364.x)) - (_458 * _364.y)) - (_460 * _364.z));
                float4 _495 = _494 - _260;
                float4 _496 = _494 + _260;
                float4 _503 = select(_495, _496, bool4(dot(_496, _496) < dot(_495, _495))) / float4(_451);
                _204 = fast::normalize(_364 - (float4(((_429.w * _503.x) + (_429.y * _503.z)) - (_429.z * _503.y), ((_429.w * _503.y) - (_429.x * _503.z)) + (_429.z * _503.x), ((_429.w * _503.z) + (_429.x * _503.y)) - (_429.y * _503.x), ((-(_429.x * _503.x)) - (_429.y * _503.y)) - (_429.z * _503.z)) * _435));
                _557 = fast::normalize(_429 + (float4(((_364.w * _503.x) + (_364.y * _503.z)) - (_364.z * _503.y), ((_364.w * _503.y) - (_364.x * _503.z)) + (_364.z * _503.x), ((_364.w * _503.z) + (_364.x * _503.y)) - (_364.y * _503.x), ((-(_364.x * _503.x)) - (_364.y * _503.y)) - (_364.z * _503.z)) * _432));
            }
            else
            {
                _204 = _364;
                _557 = _429;
            }
            gPositions._m0[_199] = JPH_HairPosition{ _428, _557 };
            _200 = _199 + gContext.cNumStrands;
        }
        gPositions._m0[_199] = JPH_HairPosition{ _201, _203 };
        gPositions._m0[_199 + gContext.cNumStrands] = JPH_HairPosition{ _197, _203 };
        break;
    } while(false);
}

