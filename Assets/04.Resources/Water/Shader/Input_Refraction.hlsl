///////////////////////////
///                     ///
///     Refraction      ///
///                     ///
///////////////////////////
float3 GetRefractionColor(float2 distortUV, float distortIntensity, Texture2D CameraDepthTex, sampler sampler_CameraDepthTex, float clipZ, float clipW, Texture2D CameraOpaqueTex, sampler sampler_CameraOpaqueTex, float2 screenPosXY)
{
    float2 uv_ScreenDistort = distortUV * distortIntensity * 0.1;

    float screenDepth = SAMPLE_TEXTURE2D(CameraDepthTex, sampler_CameraDepthTex, uv_ScreenDistort).x;

    float screenDepth_Linear = LinearEyeDepth(screenDepth, _ZBufferParams);
    float screenDepth_ClipZ = LinearEyeDepth(clipZ, _ZBufferParams);
    float refractionMask = screenDepth_Linear - screenDepth_ClipZ;

    float2 uv_Refraction = lerp(float2(0.0, 0.0), uv_ScreenDistort, 1.0 - saturate(refractionMask / (clipW * 0.5 + 0.5)));

    return SAMPLE_TEXTURE2D(CameraOpaqueTex, sampler_CameraOpaqueTex, screenPosXY + uv_Refraction).xyz;
}