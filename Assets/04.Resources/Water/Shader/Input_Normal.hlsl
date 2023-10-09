///////////////////////////////
///                         ///
///    Local-Reflection     ///
///                         ///
///////////////////////////////
float3 LocalReflection(float3 reflecDir, float3 worldPosition, float3 boxSize, float3 boxCenter)
{
    float3 a = (-boxSize - worldPosition) / reflecDir;
    float3 b = (boxSize - worldPosition) / reflecDir;
    float3 c = max(a, b);
    float d = min(min(c.x, c.y), c.z);

    float3 finalReflectionDir = d * reflecDir + worldPosition + boxCenter;
    return normalize(finalReflectionDir);
}

///////////////////////////////
///                         ///
///       UV Rotation       ///
///                         ///
///////////////////////////////
float2 RotationUV(float2 uv, float2 Center, float angle)
{
    float cosA = cos(angle / 360.0);
    float sinB = sin(angle / 360.0);
    return mul(uv - Center, float2x2(cosA, -sinB, sinB, cosA)) + Center;
}

///////////////////////////////
///                         ///
///      NormalBlending     ///
///                         ///
///////////////////////////////
float3 NormalBlending_ReorientedNormalMapping(float3 n1, float3 n2)
{
    n1.z += 1.0;
    n2.xy = -n2.xy;
    return normalize(n1 * dot(n1, n2) - n2 * n1.z);
}

///////////////////////////
///                     ///
///    RippleNormal     ///
///                     ///
///////////////////////////
float3 GetRippleNormal(Texture2D normalTex, sampler normalSampler, float2 UV, vector normalParams, vector dirParamsA, vector dirParamsB)
{
    // small tilling(XY) intensity(Z) speed(W)
    float2 uv_RippleA = RotationUV(UV * normalParams.xy, dirParamsA.xy, dirParamsA.z);
    float2 uv_RippleB = RotationUV(UV * normalParams.xy, dirParamsB.xy, dirParamsB.z);
    float speed_RippleA = dirParamsA.w * _Time.y;
    float speed_RippleB = dirParamsB.w * _Time.y;

    float3 normal_A = UnpackNormalScale(SAMPLE_TEXTURE2D(normalTex, normalSampler, uv_RippleA + speed_RippleA), normalParams.z);
    float3 normal_B = UnpackNormalScale(SAMPLE_TEXTURE2D(normalTex, normalSampler, uv_RippleB + speed_RippleB), normalParams.w);
    return NormalBlending_ReorientedNormalMapping(normal_A, normal_B);
}