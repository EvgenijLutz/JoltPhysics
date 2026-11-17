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

struct type_StructuredBuffer_float
{
    float _m0[1];
};

struct type_StructuredBuffer_v4float
{
    float4 _m0[1];
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

struct JPH_HairVelocity
{
    packed_float3 mVelocity;
    packed_float3 mAngularVelocity;
};

struct type_StructuredBuffer_JPH_HairVelocity
{
    JPH_HairVelocity _m0[1];
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

kernel void HairIntegrate(constant type_gContext& gContext [[buffer(0)]], device type_StructuredBuffer_uint& gVerticesFixed [[buffer(1)]], device type_StructuredBuffer_uint& gStrandFractions [[buffer(2)]], device type_StructuredBuffer_float& gNeutralDensity [[buffer(3)]], device type_StructuredBuffer_v4float& gVelocityAndDensity [[buffer(4)]], device type_StructuredBuffer_uint& gStrandMaterialIndex [[buffer(5)]], device type_StructuredBuffer_JPH_HairMaterial& gMaterials [[buffer(6)]], device type_StructuredBuffer_JPH_HairVelocity& gVelocities [[buffer(7)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(8)]], device type_RWStructuredBuffer_JPH_HairPosition& gPreviousPositions [[buffer(9)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        uint _107 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_107 >= gContext.cNumVertices)
        {
            break;
        }
        if ((gVerticesFixed._m0[_107 >> 5u] & (1u << (_107 & 31u))) != 0u)
        {
            break;
        }
        uint _124 = _107 % gContext.cNumStrands;
        uint _127 = gStrandMaterialIndex._m0[_124 >> 2u];
        uint _132 = (_127 >> (((_124 & 3u) << 3u) & 31u)) & 255u;
        float4 _135 = gMaterials._m0[_132].mGravityFactor;
        float4 _137 = gMaterials._m0[_132].mGridVelocityFactor;
        uint _139 = gMaterials._m0[_132].mEnableGrid;
        float _141 = gMaterials._m0[_132].mExpLinearDampingDeltaTime;
        float _143 = gMaterials._m0[_132].mExpAngularDampingDeltaTime;
        float _145 = gMaterials._m0[_132].mGridDensityForceFactor;
        uint _148 = gStrandFractions._m0[_107 >> 2u];
        float _155 = float((_148 >> (((_107 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125;
        float3 _158 = float3(gPositions._m0[_107].mPosition);
        float4 _160 = float4(gPositions._m0[_107].mRotation);
        float3 _163 = float3(gVelocities._m0[_107].mVelocity);
        float3 _165 = float3(gVelocities._m0[_107].mAngularVelocity);
        gPreviousPositions._m0[_107] = JPH_HairPosition{ _158, _160 };
        float3 _492;
        do
        {
            if (_139 == 0u)
            {
                _492 = _163;
                break;
            }
            float3 _182 = precise::min(precise::max(_158 - float3(gContext.cGridOffset), float3(0.0)) * float3(gContext.cGridScale), float3(gContext.cGridSizeMin1));
            uint3 _186 = min(uint3(_182), uint3(gContext.cGridSizeMin2));
            float3 _188 = _182 - float3(_186);
            float3 _96 = _188;
            float3 _97 = float3(1.0) - _188;
            uint3 _98 = uint3(gContext.cGridStride);
            uint3 _99 = _186;
            uint _205 = (_99.x + (_99.y * gContext.cGridStride[1])) + (_99.z * gContext.cGridStride[2]);
            uint _206 = _205 + 1u;
            uint _209 = _205 + _98.y;
            uint _210 = _209 + 1u;
            float3 _293 = (((((gVelocityAndDensity._m0[_205].xyz * ((_97.x * _97.y) * _97.z)) + (gVelocityAndDensity._m0[_206].xyz * ((_96.x * _97.y) * _97.z))) + (gVelocityAndDensity._m0[_209].xyz * ((_97.x * _96.y) * _97.z))) + (gVelocityAndDensity._m0[_210].xyz * ((_96.x * _96.y) * _97.z))) + (gVelocityAndDensity._m0[_205 + _98.z].xyz * ((_97.x * _97.y) * _96.z))) + (gVelocityAndDensity._m0[_206 + _98.z].xyz * ((_96.x * _97.y) * _96.z));
            float4 _100 = _137;
            float _345 = ((device float*)&gVelocityAndDensity._m0[_205])[3] - gNeutralDensity._m0[_205];
            float _350 = ((device float*)&gVelocityAndDensity._m0[_206])[3] - gNeutralDensity._m0[_206];
            float _355 = ((device float*)&gVelocityAndDensity._m0[_209])[3] - gNeutralDensity._m0[_209];
            float _360 = ((device float*)&gVelocityAndDensity._m0[_210])[3] - gNeutralDensity._m0[_210];
            uint _363 = _205 + _98.z;
            float _368 = ((device float*)&gVelocityAndDensity._m0[_363])[3] - gNeutralDensity._m0[_363];
            uint _371 = _206 + _98.z;
            float _376 = ((device float*)&gVelocityAndDensity._m0[_371])[3] - gNeutralDensity._m0[_371];
            uint _379 = _209 + _98.z;
            float _384 = ((device float*)&gVelocityAndDensity._m0[_379])[3] - gNeutralDensity._m0[_379];
            uint _387 = _210 + _98.z;
            float _392 = ((device float*)&gVelocityAndDensity._m0[_387])[3] - gNeutralDensity._m0[_387];
            float3 _487 = float3(((((_97.y * _97.z) * (_345 - _350)) + ((_96.y * _97.z) * (_355 - _360))) + ((_97.y * _96.z) * (_368 - _376))) + ((_96.y * _96.z) * (_384 - _392)), ((((_97.x * _97.z) * (_345 - _355)) + ((_96.x * _97.z) * (_350 - _360))) + ((_97.x * _96.z) * (_368 - _384))) + ((_96.x * _96.z) * (_376 - _392)), ((((_97.x * _97.y) * (_345 - _368)) + ((_96.x * _97.y) * (_350 - _376))) + ((_97.x * _96.y) * (_355 - _384))) + ((_96.x * _96.y) * (_360 - _392))) * _145;
            _492 = (_163 + ((((_293 + (gVelocityAndDensity._m0[_209 + _98.z].xyz * ((_97.x * _96.y) * _96.z))) + (gVelocityAndDensity._m0[_210 + _98.z].xyz * ((_96.x * _96.y) * _96.z))) - _163) * precise::min(_100.w, precise::max(_100.z, _100.y + (_155 * _100.x))))) + (_487 * gContext.cDeltaTime);
            break;
        } while(false);
        float4 _93 = _135;
        float3 _94 = _165 * _143;
        float4 _95 = _160;
        float4 _588 = float4(((_94.x * _95.w) + (_94.y * _95.z)) - (_94.z * _95.y), (((-_94.x) * _95.z) + (_94.y * _95.w)) + (_94.z * _95.x), ((_94.x * _95.y) - (_94.y * _95.x)) + (_94.z * _95.w), (((-_94.x) * _95.x) - (_94.y * _95.y)) - (_94.z * _95.z)) * gContext.cHalfDeltaTime;
        gPositions._m0[_107] = JPH_HairPosition{ _158 + (((_492 + (float3(gContext.cSubStepGravity) * precise::min(_93.w, precise::max(_93.z, _93.y + (_155 * _93.x))))) * _141) * gContext.cDeltaTime), fast::normalize(_160 + _588) };
        break;
    } while(false);
}

