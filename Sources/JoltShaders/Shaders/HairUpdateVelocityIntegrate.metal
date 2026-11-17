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

struct JPH_HairPosition
{
    packed_float3 mPosition;
    packed_float4 mRotation;
};

struct type_RWStructuredBuffer_JPH_HairPosition
{
    JPH_HairPosition _m0[1];
};

constant float _124 = {};

kernel void HairUpdateVelocityIntegrate(constant type_gContext& gContext [[buffer(0)]], constant type_gIterationContext& gIterationContext [[buffer(1)]], device type_StructuredBuffer_uint& gVerticesFixed [[buffer(2)]], device type_StructuredBuffer_uint& gStrandFractions [[buffer(3)]], device type_StructuredBuffer_v3float& gInitialPositions [[buffer(4)]], device type_StructuredBuffer_uint& gInitialBishops [[buffer(5)]], device type_StructuredBuffer_float& gNeutralDensity [[buffer(6)]], device type_StructuredBuffer_v4float& gVelocityAndDensity [[buffer(7)]], device type_StructuredBuffer_uint& gStrandMaterialIndex [[buffer(8)]], device type_StructuredBuffer_JPH_HairMaterial& gMaterials [[buffer(9)]], device type_StructuredBuffer_JPH_HairGlobalPoseTransform& gGlobalPoseTransforms [[buffer(10)]], device type_StructuredBuffer_JPH_HairCollisionShape& gCollisionShapes [[buffer(11)]], device type_StructuredBuffer_JPH_HairCollisionPlane& gCollisionPlanes [[buffer(12)]], device type_RWStructuredBuffer_JPH_HairPosition& gPreviousPositions [[buffer(13)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(14)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        uint _150 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_150 >= gContext.cNumVertices)
        {
            break;
        }
        if ((gVerticesFixed._m0[_150 >> 5u] & (1u << (_150 & 31u))) != 0u)
        {
            break;
        }
        uint _167 = _150 % gContext.cNumStrands;
        uint _170 = gStrandMaterialIndex._m0[_167 >> 2u];
        uint _175 = (_170 >> (((_167 & 3u) << 3u) & 31u)) & 255u;
        float4 _182 = gMaterials._m0[_175].mGravityFactor;
        float4 _186 = gMaterials._m0[_175].mGridVelocityFactor;
        uint _190 = gMaterials._m0[_175].mEnableGrid;
        float _194 = gMaterials._m0[_175].mExpLinearDampingDeltaTime;
        float _196 = gMaterials._m0[_175].mExpAngularDampingDeltaTime;
        float _198 = gMaterials._m0[_175].mGridDensityForceFactor;
        uint _205 = gStrandFractions._m0[_150 >> 2u];
        float _212 = float((_205 >> (((_150 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125;
        float3 _231 = float3(float(int(gInitialBishops._m0[_150] & 511u) - 255), float(int((gInitialBishops._m0[_150] >> 9u) & 511u) - 255), float((gInitialBishops._m0[_150] >> 18u) & 511u) - 255.0) * 0.0027729677967727184295654296875;
        float4 _239 = float4(_231, sqrt(precise::max(1.0 - dot(_231, _231), 0.0)));
        float4 _245;
        if ((gInitialBishops._m0[_150] & 2147483648u) != 0u)
        {
            _245 = -_239;
        }
        else
        {
            _245 = _239;
        }
        uint _247 = (gInitialBishops._m0[_150] >> 29u) & 3u;
        float4 _265;
        if (_247 == 0u)
        {
            _265 = _245.wxyz;
        }
        else
        {
            float4 _264;
            if (_247 == 1u)
            {
                _264 = _245.xwyz;
            }
            else
            {
                float4 _263;
                if (_247 == 2u)
                {
                    _263 = _245.xywz;
                }
                else
                {
                    _263 = _245;
                }
                _264 = _263;
            }
            _265 = _264;
        }
        float4 _275 = float4(gPositions._m0[_150].mRotation);
        float4 _139 = gMaterials._m0[_175].mSkinGlobalPose;
        float _292 = precise::min(_139.w, precise::max(_139.z, _139.y + (_212 * _139.x)));
        float4 _140 = float4(gGlobalPoseTransforms._m0[_167].mRotation);
        float3 _298 = (float3(gInitialPositions._m0[_150][1], gInitialPositions._m0[_150][2], gInitialPositions._m0[_150][0]) * float3(gGlobalPoseTransforms._m0[_167].mRotation[0], gGlobalPoseTransforms._m0[_167].mRotation[1], gGlobalPoseTransforms._m0[_167].mRotation[2])) - (float3(gGlobalPoseTransforms._m0[_167].mRotation[1], gGlobalPoseTransforms._m0[_167].mRotation[2], gGlobalPoseTransforms._m0[_167].mRotation[0]) * float3(gInitialPositions._m0[_150]));
        float3 _299 = _298.yzx;
        float3 _308 = (_299 * _140.w) + ((_298.zxy * float3(gGlobalPoseTransforms._m0[_167].mRotation[0], gGlobalPoseTransforms._m0[_167].mRotation[1], gGlobalPoseTransforms._m0[_167].mRotation[2])) - (float3(gGlobalPoseTransforms._m0[_167].mRotation[1], gGlobalPoseTransforms._m0[_167].mRotation[2], gGlobalPoseTransforms._m0[_167].mRotation[0]) * _299)).yzx;
        float4 _141 = float4(gGlobalPoseTransforms._m0[_167].mRotation);
        float4 _142 = _265;
        float4 _408 = float4((((_141.w * _142.x) + (_141.x * _142.w)) + (_141.y * _142.z)) - (_141.z * _142.y), (((_141.w * _142.y) - (_141.x * _142.z)) + (_141.y * _142.w)) + (_141.z * _142.x), (((_141.w * _142.z) + (_141.x * _142.y)) - (_141.y * _142.x)) + (_141.z * _142.w), (((_141.w * _142.w) - (_141.x * _142.x)) - (_141.y * _142.y)) - (_141.z * _142.z)) - _265;
        float4 _143 = gMaterials._m0[_175].mGlobalPose;
        float _422 = precise::min(_143.w, precise::max(_143.z, _143.y + (_212 * _143.x)));
        float3 _425 = float3(gPositions._m0[_150].mPosition) + (((float3(gInitialPositions._m0[_150]) + (((float3(gGlobalPoseTransforms._m0[_167].mPosition) + (float3(gInitialPositions._m0[_150]) + (_308 + _308))) - float3(gInitialPositions._m0[_150])) * _292)) - float3(gPositions._m0[_150].mPosition)) * _422);
        float4 _429 = fast::normalize(_275 + (((_265 + (_408 * _292)) - _275) * _422));
        float3 _434 = (_425 - float3(gPreviousPositions._m0[_150].mPosition)) / float3(gContext.cDeltaTime);
        float4 _134 = _429;
        float4 _135 = float4(gPreviousPositions._m0[_150].mRotation);
        float4 _136 = float4(-_135.x, -_135.y, -_135.z, _135.w);
        float3 _517 = float4((((_134.w * _136.x) + (_134.x * _136.w)) + (_134.y * _136.z)) - (_134.z * _136.y), (((_134.w * _136.y) - (_134.x * _136.z)) + (_134.y * _136.w)) + (_134.z * _136.x), (((_134.w * _136.z) + (_134.x * _136.y)) - (_134.y * _136.x)) + (_134.z * _136.w), _124).xyz;
        float3 _520 = _517 * gContext.cTwoDivDeltaTime;
        float3 _594;
        float3 _595;
        if (gMaterials._m0[_175].mEnableCollision != 0u)
        {
            float4 _137 = float4(gCollisionPlanes._m0[_150].mPlane);
            float _533 = dot(_425, float3(gCollisionPlanes._m0[_150].mPlane[0], gCollisionPlanes._m0[_150].mPlane[1], gCollisionPlanes._m0[_150].mPlane[2])) + _137.w;
            float3 _546 = float3(gCollisionShapes._m0[gCollisionPlanes._m0[_150].mShapeIndex].mLinearVelocity) + cross(float3(gCollisionShapes._m0[gCollisionPlanes._m0[_150].mShapeIndex].mAngularVelocity), (_425 - (float3(gCollisionPlanes._m0[_150].mPlane[0], gCollisionPlanes._m0[_150].mPlane[1], gCollisionPlanes._m0[_150].mPlane[2]) * _533)) - float3(gCollisionShapes._m0[gCollisionPlanes._m0[_150].mShapeIndex].mCenterOfMass));
            float4 _138 = gMaterials._m0[_175].mHairRadius;
            float _564 = ((dot(_546, float3(gCollisionPlanes._m0[_150].mPlane[0], gCollisionPlanes._m0[_150].mPlane[1], gCollisionPlanes._m0[_150].mPlane[2])) * gIterationContext.cAccumulatedDeltaTime) - _533) + precise::min(_138.w, precise::max(_138.z, _138.y + (_212 * _138.x)));
            float3 _592;
            float3 _593;
            if (_564 > 0.0)
            {
                float3 _570 = _434 - _546;
                float _571 = dot(float3(gCollisionPlanes._m0[_150].mPlane[0], gCollisionPlanes._m0[_150].mPlane[1], gCollisionPlanes._m0[_150].mPlane[2]), _570);
                float3 _591;
                if (_571 < 0.0)
                {
                    float3 _575 = float3(gCollisionPlanes._m0[_150].mPlane[0], gCollisionPlanes._m0[_150].mPlane[1], gCollisionPlanes._m0[_150].mPlane[2]) * _571;
                    float3 _576 = _570 - _575;
                    float _577 = length(_576);
                    float3 _589;
                    if (_577 > 0.0)
                    {
                        _589 = _434 - (_576 * precise::min((gMaterials._m0[_175].mFriction * _564) / (_577 * gContext.cDeltaTime), 1.0));
                    }
                    else
                    {
                        _589 = _434;
                    }
                    _591 = _589 - _575;
                }
                else
                {
                    _591 = _434;
                }
                _592 = _425 + (float3(gCollisionPlanes._m0[_150].mPlane[0], gCollisionPlanes._m0[_150].mPlane[1], gCollisionPlanes._m0[_150].mPlane[2]) * _564);
                _593 = _591;
            }
            else
            {
                _592 = _425;
                _593 = _434;
            }
            _594 = _592;
            _595 = _593;
        }
        else
        {
            _594 = _425;
            _595 = _434;
        }
        float _596 = dot(_595, _595);
        float3 _603;
        if (_596 > gMaterials._m0[_175].mMaxLinearVelocitySq)
        {
            _603 = _595 * sqrt(gMaterials._m0[_175].mMaxLinearVelocitySq / _596);
        }
        else
        {
            _603 = _595;
        }
        float _604 = dot(_520, _520);
        float3 _611;
        if (_604 > gMaterials._m0[_175].mMaxAngularVelocitySq)
        {
            _611 = _520 * sqrt(gMaterials._m0[_175].mMaxAngularVelocitySq / _604);
        }
        else
        {
            _611 = _520;
        }
        gPreviousPositions._m0[_150] = JPH_HairPosition{ _594, _429 };
        float3 _938;
        do
        {
            if (_190 == 0u)
            {
                _938 = _603;
                break;
            }
            float3 _628 = precise::min(precise::max(_594 - float3(gContext.cGridOffset), float3(0.0)) * float3(gContext.cGridScale), float3(gContext.cGridSizeMin1));
            uint3 _632 = min(uint3(_628), uint3(gContext.cGridSizeMin2));
            float3 _634 = _628 - float3(_632);
            float3 _129 = _634;
            float3 _130 = float3(1.0) - _634;
            uint3 _131 = uint3(gContext.cGridStride);
            uint3 _132 = _632;
            uint _651 = (_132.x + (_132.y * gContext.cGridStride[1])) + (_132.z * gContext.cGridStride[2]);
            uint _652 = _651 + 1u;
            uint _655 = _651 + _131.y;
            uint _656 = _655 + 1u;
            float3 _739 = (((((gVelocityAndDensity._m0[_651].xyz * ((_130.x * _130.y) * _130.z)) + (gVelocityAndDensity._m0[_652].xyz * ((_129.x * _130.y) * _130.z))) + (gVelocityAndDensity._m0[_655].xyz * ((_130.x * _129.y) * _130.z))) + (gVelocityAndDensity._m0[_656].xyz * ((_129.x * _129.y) * _130.z))) + (gVelocityAndDensity._m0[_651 + _131.z].xyz * ((_130.x * _130.y) * _129.z))) + (gVelocityAndDensity._m0[_652 + _131.z].xyz * ((_129.x * _130.y) * _129.z));
            float4 _133 = _186;
            float _791 = ((device float*)&gVelocityAndDensity._m0[_651])[3] - gNeutralDensity._m0[_651];
            float _796 = ((device float*)&gVelocityAndDensity._m0[_652])[3] - gNeutralDensity._m0[_652];
            float _801 = ((device float*)&gVelocityAndDensity._m0[_655])[3] - gNeutralDensity._m0[_655];
            float _806 = ((device float*)&gVelocityAndDensity._m0[_656])[3] - gNeutralDensity._m0[_656];
            uint _809 = _651 + _131.z;
            float _814 = ((device float*)&gVelocityAndDensity._m0[_809])[3] - gNeutralDensity._m0[_809];
            uint _817 = _652 + _131.z;
            float _822 = ((device float*)&gVelocityAndDensity._m0[_817])[3] - gNeutralDensity._m0[_817];
            uint _825 = _655 + _131.z;
            float _830 = ((device float*)&gVelocityAndDensity._m0[_825])[3] - gNeutralDensity._m0[_825];
            uint _833 = _656 + _131.z;
            float _838 = ((device float*)&gVelocityAndDensity._m0[_833])[3] - gNeutralDensity._m0[_833];
            float3 _933 = float3(((((_130.y * _130.z) * (_791 - _796)) + ((_129.y * _130.z) * (_801 - _806))) + ((_130.y * _129.z) * (_814 - _822))) + ((_129.y * _129.z) * (_830 - _838)), ((((_130.x * _130.z) * (_791 - _801)) + ((_129.x * _130.z) * (_796 - _806))) + ((_130.x * _129.z) * (_814 - _830))) + ((_129.x * _129.z) * (_822 - _838)), ((((_130.x * _130.y) * (_791 - _814)) + ((_129.x * _130.y) * (_796 - _822))) + ((_130.x * _129.y) * (_801 - _830))) + ((_129.x * _129.y) * (_806 - _838))) * _198;
            _938 = (_603 + ((((_739 + (gVelocityAndDensity._m0[_655 + _131.z].xyz * ((_130.x * _129.y) * _129.z))) + (gVelocityAndDensity._m0[_656 + _131.z].xyz * ((_129.x * _129.y) * _129.z))) - _603) * precise::min(_133.w, precise::max(_133.z, _133.y + (_212 * _133.x))))) + (_933 * gContext.cDeltaTime);
            break;
        } while(false);
        float4 _126 = _182;
        float3 _127 = _611 * _196;
        float4 _128 = _429;
        float4 _1034 = float4(((_127.x * _128.w) + (_127.y * _128.z)) - (_127.z * _128.y), (((-_127.x) * _128.z) + (_127.y * _128.w)) + (_127.z * _128.x), ((_127.x * _128.y) - (_127.y * _128.x)) + (_127.z * _128.w), (((-_127.x) * _128.x) - (_127.y * _128.y)) - (_127.z * _128.z)) * gContext.cHalfDeltaTime;
        gPositions._m0[_150] = JPH_HairPosition{ _594 + (((_938 + (float3(gContext.cSubStepGravity) * precise::min(_126.w, precise::max(_126.z, _126.y + (_212 * _126.x))))) * _194) * gContext.cDeltaTime), fast::normalize(_429 + _1034) };
        break;
    } while(false);
}

