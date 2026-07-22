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

constant float _115 = {};

kernel void HairUpdateVelocityIntegrate(constant type_gContext& gContext [[buffer(0)]], constant type_gIterationContext& gIterationContext [[buffer(1)]], device type_StructuredBuffer_uint& gVerticesFixed [[buffer(2)]], device type_StructuredBuffer_uint& gStrandFractions [[buffer(3)]], device type_StructuredBuffer_v3float& gInitialPositions [[buffer(4)]], device type_StructuredBuffer_uint& gInitialBishops [[buffer(5)]], device type_StructuredBuffer_float& gNeutralDensity [[buffer(6)]], device type_StructuredBuffer_v4float& gVelocityAndDensity [[buffer(7)]], device type_StructuredBuffer_uint& gStrandMaterialIndex [[buffer(8)]], device type_StructuredBuffer_JPH_HairMaterial& gMaterials [[buffer(9)]], device type_StructuredBuffer_JPH_HairGlobalPoseTransform& gGlobalPoseTransforms [[buffer(10)]], device type_StructuredBuffer_JPH_HairCollisionShape& gCollisionShapes [[buffer(11)]], device type_StructuredBuffer_JPH_HairCollisionPlane& gCollisionPlanes [[buffer(12)]], device type_RWStructuredBuffer_JPH_HairPosition& gPreviousPositions [[buffer(13)]], device type_RWStructuredBuffer_JPH_HairPosition& gPositions [[buffer(14)]], uint3 gl_GlobalInvocationID [[thread_position_in_grid]])
{
    do
    {
        uint _123 = gl_GlobalInvocationID.x + gContext.cNumStrands;
        if (_123 >= gContext.cNumVertices)
        {
            break;
        }
        if ((gVerticesFixed._m0[_123 >> 5u] & (1u << (_123 & 31u))) != 0u)
        {
            break;
        }
        uint _138 = _123 % gContext.cNumStrands;
        uint _141 = gStrandMaterialIndex._m0[_138 >> 2u];
        uint _146 = (_141 >> (((_138 & 3u) << 3u) & 31u)) & 255u;
        float4 _148 = gMaterials._m0[_146].mGlobalPose;
        float4 _152 = gMaterials._m0[_146].mGravityFactor;
        float4 _156 = gMaterials._m0[_146].mGridVelocityFactor;
        uint _160 = gMaterials._m0[_146].mEnableGrid;
        float _164 = gMaterials._m0[_146].mExpLinearDampingDeltaTime;
        float _166 = gMaterials._m0[_146].mExpAngularDampingDeltaTime;
        float _168 = gMaterials._m0[_146].mGridDensityForceFactor;
        uint _175 = gStrandFractions._m0[_123 >> 2u];
        float _182 = float((_175 >> (((_123 & 3u) << 3u) & 31u)) & 255u) * 0.0039215688593685626983642578125;
        float3 _201 = float3(float(int(gInitialBishops._m0[_123] & 511u) - 255), float(int((gInitialBishops._m0[_123] >> 9u) & 511u) - 255), float((gInitialBishops._m0[_123] >> 18u) & 511u) - 255.0) * 0.0027729677967727184295654296875;
        float4 _209 = float4(_201, sqrt(precise::max(1.0 - dot(_201, _201), 0.0)));
        float4 _215;
        if ((gInitialBishops._m0[_123] & 2147483648u) != 0u)
        {
            _215 = -_209;
        }
        else
        {
            _215 = _209;
        }
        uint _217 = (gInitialBishops._m0[_123] >> 29u) & 3u;
        float4 _235;
        if (_217 == 0u)
        {
            _235 = _215.wxyz;
        }
        else
        {
            float4 _234;
            if (_217 == 1u)
            {
                _234 = _215.xwyz;
            }
            else
            {
                float4 _233;
                if (_217 == 2u)
                {
                    _233 = _215.xywz;
                }
                else
                {
                    _233 = _215;
                }
                _234 = _233;
            }
            _235 = _234;
        }
        float4 _244 = float4(gPositions._m0[_123].mRotation);
        float _257 = precise::min(gMaterials._m0[_146].mSkinGlobalPose.w, precise::max(gMaterials._m0[_146].mSkinGlobalPose.z, gMaterials._m0[_146].mSkinGlobalPose.y + (_182 * gMaterials._m0[_146].mSkinGlobalPose.x)));
        float3 _263 = (float3(gInitialPositions._m0[_123][1], gInitialPositions._m0[_123][2], gInitialPositions._m0[_123][0]) * float3(gGlobalPoseTransforms._m0[_138].mRotation[0], gGlobalPoseTransforms._m0[_138].mRotation[1], gGlobalPoseTransforms._m0[_138].mRotation[2])) - (float3(gGlobalPoseTransforms._m0[_138].mRotation[1], gGlobalPoseTransforms._m0[_138].mRotation[2], gGlobalPoseTransforms._m0[_138].mRotation[0]) * float3(gInitialPositions._m0[_123]));
        float3 _264 = _263.yzx;
        float3 _272 = (_264 * gGlobalPoseTransforms._m0[_138].mRotation[3]) + ((_263.zxy * float3(gGlobalPoseTransforms._m0[_138].mRotation[0], gGlobalPoseTransforms._m0[_138].mRotation[1], gGlobalPoseTransforms._m0[_138].mRotation[2])) - (float3(gGlobalPoseTransforms._m0[_138].mRotation[1], gGlobalPoseTransforms._m0[_138].mRotation[2], gGlobalPoseTransforms._m0[_138].mRotation[0]) * _264)).yzx;
        float _325 = precise::min(_148.w, precise::max(_148.z, _148.y + (_182 * _148.x)));
        float3 _328 = float3(gPositions._m0[_123].mPosition) + (((float3(gInitialPositions._m0[_123]) + (((float3(gGlobalPoseTransforms._m0[_138].mPosition) + (float3(gInitialPositions._m0[_123]) + (_272 + _272))) - float3(gInitialPositions._m0[_123])) * _257)) - float3(gPositions._m0[_123].mPosition)) * _325);
        float4 _332 = fast::normalize(_244 + (((_235 + ((float4((((gGlobalPoseTransforms._m0[_138].mRotation[3] * _235.x) + (gGlobalPoseTransforms._m0[_138].mRotation[0] * _235.w)) + (gGlobalPoseTransforms._m0[_138].mRotation[1] * _235.z)) - (gGlobalPoseTransforms._m0[_138].mRotation[2] * _235.y), (((gGlobalPoseTransforms._m0[_138].mRotation[3] * _235.y) - (gGlobalPoseTransforms._m0[_138].mRotation[0] * _235.z)) + (gGlobalPoseTransforms._m0[_138].mRotation[1] * _235.w)) + (gGlobalPoseTransforms._m0[_138].mRotation[2] * _235.x), (((gGlobalPoseTransforms._m0[_138].mRotation[3] * _235.z) + (gGlobalPoseTransforms._m0[_138].mRotation[0] * _235.y)) - (gGlobalPoseTransforms._m0[_138].mRotation[1] * _235.x)) + (gGlobalPoseTransforms._m0[_138].mRotation[2] * _235.w), (((gGlobalPoseTransforms._m0[_138].mRotation[3] * _235.w) - (gGlobalPoseTransforms._m0[_138].mRotation[0] * _235.x)) - (gGlobalPoseTransforms._m0[_138].mRotation[1] * _235.y)) - (gGlobalPoseTransforms._m0[_138].mRotation[2] * _235.z)) - _235) * _257)) - _244) * _325));
        float3 _337 = (_328 - float3(gPreviousPositions._m0[_123].mPosition)) / float3(gContext.cDeltaTime);
        float _339 = -gPreviousPositions._m0[_123].mRotation[0];
        float _341 = -gPreviousPositions._m0[_123].mRotation[1];
        float _343 = -gPreviousPositions._m0[_123].mRotation[2];
        float _345 = _332.w;
        float _347 = _332.x;
        float _350 = _332.y;
        float _353 = _332.z;
        float3 _374 = float4((((_345 * _339) + (_347 * gPreviousPositions._m0[_123].mRotation[3])) + (_350 * _343)) - (_353 * _341), (((_345 * _341) - (_347 * _343)) + (_350 * gPreviousPositions._m0[_123].mRotation[3])) + (_353 * _339), (((_345 * _343) + (_347 * _341)) - (_350 * _339)) + (_353 * gPreviousPositions._m0[_123].mRotation[3]), _115).xyz * gContext.cTwoDivDeltaTime;
        float3 _438;
        float3 _439;
        if (gMaterials._m0[_146].mEnableCollision != 0u)
        {
            float _385 = dot(_328, float3(gCollisionPlanes._m0[_123].mPlane[0], gCollisionPlanes._m0[_123].mPlane[1], gCollisionPlanes._m0[_123].mPlane[2])) + gCollisionPlanes._m0[_123].mPlane[3];
            float3 _396 = float3(gCollisionShapes._m0[gCollisionPlanes._m0[_123].mShapeIndex].mLinearVelocity) + cross(float3(gCollisionShapes._m0[gCollisionPlanes._m0[_123].mShapeIndex].mAngularVelocity), (_328 - (float3(gCollisionPlanes._m0[_123].mPlane[0], gCollisionPlanes._m0[_123].mPlane[1], gCollisionPlanes._m0[_123].mPlane[2]) * _385)) - float3(gCollisionShapes._m0[gCollisionPlanes._m0[_123].mShapeIndex].mCenterOfMass));
            float _410 = ((dot(_396, float3(gCollisionPlanes._m0[_123].mPlane[0], gCollisionPlanes._m0[_123].mPlane[1], gCollisionPlanes._m0[_123].mPlane[2])) * gIterationContext.cAccumulatedDeltaTime) - _385) + precise::min(gMaterials._m0[_146].mHairRadius.w, precise::max(gMaterials._m0[_146].mHairRadius.z, gMaterials._m0[_146].mHairRadius.y + (_182 * gMaterials._m0[_146].mHairRadius.x)));
            float3 _436;
            float3 _437;
            if (_410 > 0.0)
            {
                float3 _416 = _337 - _396;
                float _417 = dot(float3(gCollisionPlanes._m0[_123].mPlane[0], gCollisionPlanes._m0[_123].mPlane[1], gCollisionPlanes._m0[_123].mPlane[2]), _416);
                float3 _435;
                if (_417 < 0.0)
                {
                    float3 _421 = float3(gCollisionPlanes._m0[_123].mPlane[0], gCollisionPlanes._m0[_123].mPlane[1], gCollisionPlanes._m0[_123].mPlane[2]) * _417;
                    float3 _422 = _416 - _421;
                    float _423 = length(_422);
                    float3 _433;
                    if (_423 > 0.0)
                    {
                        _433 = _337 - (_422 * precise::min((gMaterials._m0[_146].mFriction * _410) / (_423 * gContext.cDeltaTime), 1.0));
                    }
                    else
                    {
                        _433 = _337;
                    }
                    _435 = _433 - _421;
                }
                else
                {
                    _435 = _337;
                }
                _436 = _328 + (float3(gCollisionPlanes._m0[_123].mPlane[0], gCollisionPlanes._m0[_123].mPlane[1], gCollisionPlanes._m0[_123].mPlane[2]) * _410);
                _437 = _435;
            }
            else
            {
                _436 = _328;
                _437 = _337;
            }
            _438 = _436;
            _439 = _437;
        }
        else
        {
            _438 = _328;
            _439 = _337;
        }
        float _440 = dot(_439, _439);
        float3 _447;
        if (_440 > gMaterials._m0[_146].mMaxLinearVelocitySq)
        {
            _447 = _439 * sqrt(gMaterials._m0[_146].mMaxLinearVelocitySq / _440);
        }
        else
        {
            _447 = _439;
        }
        float _448 = dot(_374, _374);
        float3 _455;
        if (_448 > gMaterials._m0[_146].mMaxAngularVelocitySq)
        {
            _455 = _374 * sqrt(gMaterials._m0[_146].mMaxAngularVelocitySq / _448);
        }
        else
        {
            _455 = _374;
        }
        gPreviousPositions._m0[_123] = JPH_HairPosition{ _438, _332 };
        float3 _654;
        do
        {
            if (_160 == 0u)
            {
                _654 = _447;
                break;
            }
            float3 _471 = precise::min(precise::max(_438 - float3(gContext.cGridOffset), float3(0.0)) * float3(gContext.cGridScale), float3(gContext.cGridSizeMin1));
            uint3 _475 = min(uint3(_471), uint3(gContext.cGridSizeMin2));
            float3 _477 = _471 - float3(_475);
            float3 _478 = float3(1.0) - _477;
            uint _491 = (_475.x + (_475.y * gContext.cGridStride[1])) + (_475.z * gContext.cGridStride[2]);
            uint _492 = _491 + 1u;
            uint _494 = _491 + gContext.cGridStride[1];
            uint _495 = _494 + 1u;
            float _499 = _478.x;
            float _500 = _478.y;
            float _501 = _499 * _500;
            float _502 = _478.z;
            float _508 = _477.x;
            float _509 = _508 * _500;
            float _516 = _477.y;
            float _517 = _499 * _516;
            float _524 = _508 * _516;
            uint _529 = _491 + gContext.cGridStride[2];
            float _533 = _477.z;
            uint _537 = _492 + gContext.cGridStride[2];
            uint _544 = _494 + gContext.cGridStride[2];
            uint _551 = _495 + gContext.cGridStride[2];
            float3 _568 = _447 + ((((((((((gVelocityAndDensity._m0[_491].xyz * (_501 * _502)) + (gVelocityAndDensity._m0[_492].xyz * (_509 * _502))) + (gVelocityAndDensity._m0[_494].xyz * (_517 * _502))) + (gVelocityAndDensity._m0[_495].xyz * (_524 * _502))) + (gVelocityAndDensity._m0[_529].xyz * (_501 * _533))) + (gVelocityAndDensity._m0[_537].xyz * (_509 * _533))) + (gVelocityAndDensity._m0[_544].xyz * (_517 * _533))) + (gVelocityAndDensity._m0[_551].xyz * (_524 * _533))) - _447) * precise::min(_156.w, precise::max(_156.z, _156.y + (_182 * _156.x))));
            float _573 = ((device float*)&gVelocityAndDensity._m0[_491])[3] - gNeutralDensity._m0[_491];
            float _578 = ((device float*)&gVelocityAndDensity._m0[_492])[3] - gNeutralDensity._m0[_492];
            float _583 = ((device float*)&gVelocityAndDensity._m0[_494])[3] - gNeutralDensity._m0[_494];
            float _588 = ((device float*)&gVelocityAndDensity._m0[_495])[3] - gNeutralDensity._m0[_495];
            float _593 = ((device float*)&gVelocityAndDensity._m0[_529])[3] - gNeutralDensity._m0[_529];
            float _598 = ((device float*)&gVelocityAndDensity._m0[_537])[3] - gNeutralDensity._m0[_537];
            float _603 = ((device float*)&gVelocityAndDensity._m0[_544])[3] - gNeutralDensity._m0[_544];
            float _608 = ((device float*)&gVelocityAndDensity._m0[_551])[3] - gNeutralDensity._m0[_551];
            float3 _653 = _568 + ((float3(((((_500 * _502) * (_573 - _578)) + ((_516 * _502) * (_583 - _588))) + ((_500 * _533) * (_593 - _598))) + ((_516 * _533) * (_603 - _608)), ((((_499 * _502) * (_573 - _583)) + ((_508 * _502) * (_578 - _588))) + ((_499 * _533) * (_593 - _603))) + ((_508 * _533) * (_598 - _608)), (((_501 * (_573 - _593)) + (_509 * (_578 - _598))) + (_517 * (_583 - _603))) + (_524 * (_588 - _608))) * _168) * gContext.cDeltaTime);
            _654 = _653;
            break;
        } while(false);
        float3 _668 = _455 * _166;
        float _671 = _668.x;
        float _673 = _668.y;
        float _676 = _668.z;
        float _679 = -_671;
        gPositions._m0[_123] = JPH_HairPosition{ _438 + (((_654 + (float3(gContext.cSubStepGravity) * precise::min(_152.w, precise::max(_152.z, _152.y + (_182 * _152.x))))) * _164) * gContext.cDeltaTime), fast::normalize(_332 + (float4(((_671 * _345) + (_673 * _353)) - (_676 * _350), ((_679 * _353) + (_673 * _345)) + (_676 * _347), ((_671 * _350) - (_673 * _347)) + (_676 * _345), ((_679 * _347) - (_673 * _350)) - (_676 * _353)) * gContext.cHalfDeltaTime)) };
        break;
    } while(false);
}

