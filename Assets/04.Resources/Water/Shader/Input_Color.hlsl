#include "./BRDFLibrary.cginc"


///////////////////////////////
///                         ///
///       ToneMapping       ///
///                         ///
///////////////////////////////
float3 ACES_Tonemapping(float3 color_input)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    float3 encode_color = saturate((color_input * (a * color_input + b)) / (color_input * (c * color_input + d) + e));
    return encode_color;
}

////////////////////////////////////////////////
///                                          ///
///    ReconstructWorldPositionfromDepth     ///
///                                          ///
////////////////////////////////////////////////
float4 ReconstructWorldPosition(Texture2D CameraDepthTex, sampler sampler_CameraDepthTex, float2 screenPosXY, float3 viewPos_world)
{
    float depthTexture = SAMPLE_TEXTURE2D(CameraDepthTex, sampler_CameraDepthTex, screenPosXY).x;

    float depth = LinearEyeDepth(depthTexture, _ZBufferParams);
    // Restructe world position from depth
    float4 depthVS = float4(1.0, 1.0, 1.0, 1.0);
    depthVS.xy = viewPos_world.xy * depth / - viewPos_world.z;
    depthVS.z = depth;
    
    return mul(unity_CameraToWorld, depthVS);
}

////////////////////////////
///                      ///
///    FresnelFactor     ///
///                      ///
////////////////////////////
float GetFresnelFactor(float3 normal, float3 viewDir, float range, float intensity)
{
    float factor = saturate(dot(normal, viewDir));

    return saturate(pow(factor, range) * intensity);
}

/////////////////////////
//    Water Specular   //
/////////////////////////
float3 GetWaterSpecularColor(float3 specular, float3 normal, float radius, float3 lightDir, float3 viewDir, float3 lightCol)
{
    float a2 = Pow4_UE4(pow(saturate(normal.z * 0.5 + 0.5), radius * 2.0));
    float3 H = normalize(lightDir + viewDir);
    float NoH = saturate(dot(normal, H));
    float NoV = saturate(abs(dot(normal, viewDir)) + 1e-5);
    float VoH = saturate(dot(viewDir, H));
    float NoL = saturate(dot(normal, lightDir));
    float D = D_GGX_UE4(a2, NoH);
    float Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    float3 F = F_Schlick_UE4(specular, VoH);
    float3 radians = NoL * lightCol;
    
    return (D * Vis) * F * radians;
}