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

struct type_StructuredBuffer_uint
{
    uint _m0[1];
};

struct type_StructuredBuffer_v3float
{
    packed_float3 _m0[1];
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

struct type_StructuredBuffer_JPH_HairPosition
{
    JPH_HairPosition _m0[1];
};

struct JPH_HairGlobalPoseTransform
{
    packed_float3 mPosition;
    packed_float4 mRotation;
};

struct type_StructuredBuffer_JPH_HairGlobalPoseTransform
{
    JPH_HairGlobalPoseTransform _m0[1];
};

struct JPH_HairCollisionShape
{
    packed_float3 mCenterOfMass;
    packed_float3 mLinearVelocity;
    packed_float3 mAngularVelocity;
};

struct type_StructuredBuffer_JPH_HairCollisionShape
{
    JPH_HairCollisionShape _m0[1];
};

struct JPH_HairCollisionPlane
{
    packed_float4 mPlane;
    uint mShapeIndex;
};

struct type_StructuredBuffer_JPH_HairCollisionPlane
{
    JPH_HairCollisionPlane _m0[1];
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

constant float _107 = {};

kernel void HairUpdateVelocity(constant type_gContext& gContext [[buffer(0)]], constant type_gIterationContext& gIterationContext [[buffer(1)]], device type_StructuredBuffer_uint& gVerticesFixed [[buffer(2)]], device type_StructuredBuffer_uint& gStrandFractions [[buffer(3)]], device type_StructuredBuffer_v3float& gInitialPositions [[buffer(4)]], device type_StructuredBuffer_uint& gInitialBishops [[buffer(5)]], device type_StructuredBuffer_uint& gStrandMaterialIndex [[buffer(6)]], device type_StructuredBuffer_JPH_HairMaterial& gMaterials [[buffer(7)]], device type_StructuredBuffer_JPH_HairPosition& gPreviousPositions [[buffer(8)]], device type_StructuredBuffer_JPH_HairGlobalPoseTransform& gGlobalPoseTransforms [[buffer(9)]], device type_StructuredBuffer_JPH_HairCollisionShape& gCollisionShapes [[buffer(10)]], device type_StructuredBuffer_JPH_HairCollisionPlane& gCollisionPlanes [[buffer(11)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(12)]], device type_RWStructuredBuffer_JPH_HairVelocity& gVelocities [[buffer(13)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        uint _125 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_125 >= gContext.cNumVertices)
        {
            break;
        }
        if ((gVerticesFixed._m0[_125 >> 5u] & (1u << (_125 & 31u))) != 0u)
        {
            break;
        }
        uint _142 = _125 % gContext.cNumStrands;
        uint _150 = (gStrandMaterialIndex._m0[_142 >> 2u] >> (((_142 & 3u) << 3u) & 31u)) & 255u;
        float _175 = float((gStrandFractions._m0[_125 >> 2u] >> (((_125 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125;
        float3 _194 = float3(float(int(gInitialBishops._m0[_125] & 511u) - 255), float(int((gInitialBishops._m0[_125] >> 9u) & 511u) - 255), float((gInitialBishops._m0[_125] >> 18u) & 511u) - 255.0) * 0.0027729677967727184295654296875;
        float4 _202 = float4(_194, sqrt(precise::max(1.0 - dot(_194, _194), 0.0)));
        float4 _208;
        if ((gInitialBishops._m0[_125] & 2147483648u) != 0u)
        {
            _208 = -_202;
        }
        else
        {
            _208 = _202;
        }
        uint _210 = (gInitialBishops._m0[_125] >> 29u) & 3u;
        float4 _228;
        if (_210 == 0u)
        {
            _228 = _208.wxyz;
        }
        else
        {
            float4 _227;
            if (_210 == 1u)
            {
                _227 = _208.xwyz;
            }
            else
            {
                float4 _226;
                if (_210 == 2u)
                {
                    _226 = _208.xywz;
                }
                else
                {
                    _226 = _208;
                }
                _227 = _226;
            }
            _228 = _227;
        }
        float4 _114 = gMaterials._m0[_150].mSkinGlobalPose;
        float _255 = precise::min(_114.w, precise::max(_114.z, _114.y + (_175 * _114.x)));
        float4 _115 = float4(gGlobalPoseTransforms._m0[_142].mRotation);
        float3 _261 = (float3(gInitialPositions._m0[_125][1], gInitialPositions._m0[_125][2], gInitialPositions._m0[_125][0]) * float3(gGlobalPoseTransforms._m0[_142].mRotation[0], gGlobalPoseTransforms._m0[_142].mRotation[1], gGlobalPoseTransforms._m0[_142].mRotation[2])) - (float3(gGlobalPoseTransforms._m0[_142].mRotation[1], gGlobalPoseTransforms._m0[_142].mRotation[2], gGlobalPoseTransforms._m0[_142].mRotation[0]) * float3(gInitialPositions._m0[_125]));
        float3 _262 = _261.yzx;
        float3 _271 = (_262 * _115.w) + ((_261.zxy * float3(gGlobalPoseTransforms._m0[_142].mRotation[0], gGlobalPoseTransforms._m0[_142].mRotation[1], gGlobalPoseTransforms._m0[_142].mRotation[2])) - (float3(gGlobalPoseTransforms._m0[_142].mRotation[1], gGlobalPoseTransforms._m0[_142].mRotation[2], gGlobalPoseTransforms._m0[_142].mRotation[0]) * _262)).yzx;
        float4 _116 = float4(gGlobalPoseTransforms._m0[_142].mRotation);
        float4 _117 = _228;
        float4 _371 = float4((((_116.w * _117.x) + (_116.x * _117.w)) + (_116.y * _117.z)) - (_116.z * _117.y), (((_116.w * _117.y) - (_116.x * _117.z)) + (_116.y * _117.w)) + (_116.z * _117.x), (((_116.w * _117.z) + (_116.x * _117.y)) - (_116.y * _117.x)) + (_116.z * _117.w), (((_116.w * _117.w) - (_116.x * _117.x)) - (_116.y * _117.y)) - (_116.z * _117.z)) - _228;
        float4 _118 = gMaterials._m0[_150].mGlobalPose;
        float _385 = precise::min(_118.w, precise::max(_118.z, _118.y + (_175 * _118.x)));
        float3 _388 = float3(gPositions._m0[_125].mPosition) + (((float3(gInitialPositions._m0[_125]) + (((float3(gGlobalPoseTransforms._m0[_142].mPosition) + (float3(gInitialPositions._m0[_125]) + (_271 + _271))) - float3(gInitialPositions._m0[_125])) * _255)) - float3(gPositions._m0[_125].mPosition)) * _385);
        float4 _392 = fast::normalize(float4(gPositions._m0[_125].mRotation) + (((_228 + (_371 * _255)) - float4(gPositions._m0[_125].mRotation)) * _385));
        float3 _397 = (_388 - float3(gPreviousPositions._m0[_125].mPosition)) / float3(gContext.cDeltaTime);
        float4 _109 = _392;
        float4 _110 = float4(gPreviousPositions._m0[_125].mRotation);
        float4 _111 = float4(-_110.x, -_110.y, -_110.z, _110.w);
        float3 _480 = float4((((_109.w * _111.x) + (_109.x * _111.w)) + (_109.y * _111.z)) - (_109.z * _111.y), (((_109.w * _111.y) - (_109.x * _111.z)) + (_109.y * _111.w)) + (_109.z * _111.x), (((_109.w * _111.z) + (_109.x * _111.y)) - (_109.y * _111.x)) + (_109.z * _111.w), _107).xyz;
        float3 _483 = _480 * gContext.cTwoDivDeltaTime;
        float3 _557;
        float3 _558;
        if (gMaterials._m0[_150].mEnableCollision != 0u)
        {
            float4 _112 = float4(gCollisionPlanes._m0[_125].mPlane);
            float _496 = dot(_388, float3(gCollisionPlanes._m0[_125].mPlane[0], gCollisionPlanes._m0[_125].mPlane[1], gCollisionPlanes._m0[_125].mPlane[2])) + _112.w;
            float3 _509 = float3(gCollisionShapes._m0[gCollisionPlanes._m0[_125].mShapeIndex].mLinearVelocity) + cross(float3(gCollisionShapes._m0[gCollisionPlanes._m0[_125].mShapeIndex].mAngularVelocity), (_388 - (float3(gCollisionPlanes._m0[_125].mPlane[0], gCollisionPlanes._m0[_125].mPlane[1], gCollisionPlanes._m0[_125].mPlane[2]) * _496)) - float3(gCollisionShapes._m0[gCollisionPlanes._m0[_125].mShapeIndex].mCenterOfMass));
            float4 _113 = gMaterials._m0[_150].mHairRadius;
            float _527 = ((dot(_509, float3(gCollisionPlanes._m0[_125].mPlane[0], gCollisionPlanes._m0[_125].mPlane[1], gCollisionPlanes._m0[_125].mPlane[2])) * gIterationContext.cAccumulatedDeltaTime) - _496) + precise::min(_113.w, precise::max(_113.z, _113.y + (_175 * _113.x)));
            float3 _555;
            float3 _556;
            if (_527 > 0.0)
            {
                float3 _533 = _397 - _509;
                float _534 = dot(float3(gCollisionPlanes._m0[_125].mPlane[0], gCollisionPlanes._m0[_125].mPlane[1], gCollisionPlanes._m0[_125].mPlane[2]), _533);
                float3 _554;
                if (_534 < 0.0)
                {
                    float3 _538 = float3(gCollisionPlanes._m0[_125].mPlane[0], gCollisionPlanes._m0[_125].mPlane[1], gCollisionPlanes._m0[_125].mPlane[2]) * _534;
                    float3 _539 = _533 - _538;
                    float _540 = length(_539);
                    float3 _552;
                    if (_540 > 0.0)
                    {
                        _552 = _397 - (_539 * precise::min((gMaterials._m0[_150].mFriction * _527) / (_540 * gContext.cDeltaTime), 1.0));
                    }
                    else
                    {
                        _552 = _397;
                    }
                    _554 = _552 - _538;
                }
                else
                {
                    _554 = _397;
                }
                _555 = _388 + (float3(gCollisionPlanes._m0[_125].mPlane[0], gCollisionPlanes._m0[_125].mPlane[1], gCollisionPlanes._m0[_125].mPlane[2]) * _527);
                _556 = _554;
            }
            else
            {
                _555 = _388;
                _556 = _397;
            }
            _557 = _555;
            _558 = _556;
        }
        else
        {
            _557 = _388;
            _558 = _397;
        }
        float _559 = dot(_558, _558);
        float3 _566;
        if (_559 > gMaterials._m0[_150].mMaxLinearVelocitySq)
        {
            _566 = _558 * sqrt(gMaterials._m0[_150].mMaxLinearVelocitySq / _559);
        }
        else
        {
            _566 = _558;
        }
        float _567 = dot(_483, _483);
        float3 _574;
        if (_567 > gMaterials._m0[_150].mMaxAngularVelocitySq)
        {
            _574 = _483 * sqrt(gMaterials._m0[_150].mMaxAngularVelocitySq / _567);
        }
        else
        {
            _574 = _483;
        }
        gPositions._m0[_125] = JPH_HairPosition{ _557, _392 };
        gVelocities._m0[_125] = JPH_HairVelocity{ _566, _574 };
        break;
    } while(false);
}

