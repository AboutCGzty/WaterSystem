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
float3 GetRippleNormal(Texture2D normalTex, sampler normalSampler, float2 UV, vector normalParams)
{
    // small tilling(XY) intensity(Z) speed(W)
    float2 uv_Ripple = UV * normalParams.xy;
    float speed_Ripple = normalParams.w * _Time.y;

    float3 normal_A = UnpackNormalScale(SAMPLE_TEXTURE2D(normalTex, normalSampler, uv_Ripple + speed_Ripple), normalParams.z * 0.1);
    float3 normal_B = UnpackNormalScale(SAMPLE_TEXTURE2D(normalTex, normalSampler, -uv_Ripple + speed_Ripple), normalParams.z * 0.1);
    return NormalBlending_ReorientedNormalMapping(normal_A, normal_B);
}