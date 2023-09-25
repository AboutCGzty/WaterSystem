///////////////////////////
///                     ///
///      Caustics       ///
///                     ///
///////////////////////////
float3 GetCausticsColor(Texture2D causticsTex, sampler causticsSampler, float2 UV, vector causticsParams, float2 distortDir, float distortStrength)
{
    // small tilling(XY) intensity(Z) speed(W)
    float2 uv_Caustics = UV * causticsParams.xy + distortDir * distortStrength;
    float speed_Caustics = causticsParams.w * _Time.y;

    float3 caustics_A = SAMPLE_TEXTURE2D(causticsTex, causticsSampler, uv_Caustics + speed_Caustics).xyz;
    float3 caustics_B = SAMPLE_TEXTURE2D(causticsTex, causticsSampler, -uv_Caustics + speed_Caustics * 0.8).xyz;

    return min(caustics_A, caustics_B) * max(0.0, causticsParams.z);
}