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
        uint _92 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_92 >= gContext.cNumVertices)
        {
            break;
        }
        if ((gVerticesFixed._m0[_92 >> 5u] & (1u << (_92 & 31u))) != 0u)
        {
            break;
        }
        uint _107 = _92 % gContext.cNumStrands;
        uint _110 = gStrandMaterialIndex._m0[_107 >> 2u];
        uint _115 = (_110 >> (((_107 & 3u) << 3u) & 31u)) & 255u;
        float4 _117 = gMaterials._m0[_115].mGravityFactor;
        float4 _119 = gMaterials._m0[_115].mGridVelocityFactor;
        uint _121 = gMaterials._m0[_115].mEnableGrid;
        float _123 = gMaterials._m0[_115].mExpLinearDampingDeltaTime;
        float _125 = gMaterials._m0[_115].mExpAngularDampingDeltaTime;
        float _127 = gMaterials._m0[_115].mGridDensityForceFactor;
        uint _130 = gStrandFractions._m0[_92 >> 2u];
        float _137 = float((_130 >> (((_92 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125;
        float3 _140 = float3(gPositions._m0[_92].mPosition);
        float4 _142 = float4(gPositions._m0[_92].mRotation);
        float3 _144 = float3(gVelocities._m0[_92].mVelocity);
        float3 _146 = float3(gVelocities._m0[_92].mAngularVelocity);
        gPreviousPositions._m0[_92] = JPH_HairPosition{ _140, _142 };
        float3 _348;
        do
        {
            if (_121 == 0u)
            {
                _348 = _144;
                break;
            }
            float3 _163 = precise::min(precise::max(_140 - float3(gContext.cGridOffset), float3(0.0)) * float3(gContext.cGridScale), float3(gContext.cGridSizeMin1));
            uint3 _167 = min(uint3(_163), uint3(gContext.cGridSizeMin2));
            float3 _169 = _163 - float3(_167);
            float3 _170 = float3(1.0) - _169;
            uint _183 = (_167.x + (_167.y * gContext.cGridStride[1])) + (_167.z * gContext.cGridStride[2]);
            uint _184 = _183 + 1u;
            uint _186 = _183 + gContext.cGridStride[1];
            uint _187 = _186 + 1u;
            float _191 = _170.x;
            float _192 = _170.y;
            float _193 = _191 * _192;
            float _194 = _170.z;
            float _200 = _169.x;
            float _201 = _200 * _192;
            float _208 = _169.y;
            float _209 = _191 * _208;
            float _216 = _200 * _208;
            uint _221 = _183 + gContext.cGridStride[2];
            float _225 = _169.z;
            uint _229 = _184 + gContext.cGridStride[2];
            uint _236 = _186 + gContext.cGridStride[2];
            uint _243 = _187 + gContext.cGridStride[2];
            float3 _260 = _144 + ((((((((((gVelocityAndDensity._m0[_183].xyz * (_193 * _194)) + (gVelocityAndDensity._m0[_184].xyz * (_201 * _194))) + (gVelocityAndDensity._m0[_186].xyz * (_209 * _194))) + (gVelocityAndDensity._m0[_187].xyz * (_216 * _194))) + (gVelocityAndDensity._m0[_221].xyz * (_193 * _225))) + (gVelocityAndDensity._m0[_229].xyz * (_201 * _225))) + (gVelocityAndDensity._m0[_236].xyz * (_209 * _225))) + (gVelocityAndDensity._m0[_243].xyz * (_216 * _225))) - _144) * precise::min(_119.w, precise::max(_119.z, _119.y + (_137 * _119.x))));
            float _265 = ((device float*)&gVelocityAndDensity._m0[_183])[3] - gNeutralDensity._m0[_183];
            float _270 = ((device float*)&gVelocityAndDensity._m0[_184])[3] - gNeutralDensity._m0[_184];
            float _275 = ((device float*)&gVelocityAndDensity._m0[_186])[3] - gNeutralDensity._m0[_186];
            float _280 = ((device float*)&gVelocityAndDensity._m0[_187])[3] - gNeutralDensity._m0[_187];
            float _285 = ((device float*)&gVelocityAndDensity._m0[_221])[3] - gNeutralDensity._m0[_221];
            float _290 = ((device float*)&gVelocityAndDensity._m0[_229])[3] - gNeutralDensity._m0[_229];
            float _295 = ((device float*)&gVelocityAndDensity._m0[_236])[3] - gNeutralDensity._m0[_236];
            float _300 = ((device float*)&gVelocityAndDensity._m0[_243])[3] - gNeutralDensity._m0[_243];
            float3 _347 = _260 + ((float3(((((_192 * _194) * (_265 - _270)) + ((_208 * _194) * (_275 - _280))) + ((_192 * _225) * (_285 - _290))) + ((_208 * _225) * (_295 - _300)), ((((_191 * _194) * (_265 - _275)) + ((_200 * _194) * (_270 - _280))) + ((_191 * _225) * (_285 - _295))) + ((_200 * _225) * (_290 - _300)), (((_193 * (_265 - _285)) + (_201 * (_270 - _290))) + (_209 * (_275 - _295))) + (_216 * (_280 - _300))) * _127) * gContext.cDeltaTime);
            _348 = _347;
            break;
        } while(false);
        float3 _362 = _146 * _125;
        float _367 = _362.x;
        float _370 = _362.y;
        float _374 = _362.z;
        float _378 = -_367;
        gPositions._m0[_92] = JPH_HairPosition{ _140 + (((_348 + (float3(gContext.cSubStepGravity) * precise::min(_117.w, precise::max(_117.z, _117.y + (_137 * _117.x))))) * _123) * gContext.cDeltaTime), fast::normalize(_142 + (float4(((_367 * _142.w) + (_370 * _142.z)) - (_374 * _142.y), ((_378 * _142.z) + (_370 * _142.w)) + (_374 * _142.x), ((_367 * _142.y) - (_370 * _142.x)) + (_374 * _142.w), ((_378 * _142.x) - (_370 * _142.y)) - (_374 * _142.z)) * gContext.cHalfDeltaTime)) };
        break;
    } while(false);
}

