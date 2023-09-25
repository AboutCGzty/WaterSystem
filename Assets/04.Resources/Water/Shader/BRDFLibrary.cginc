#ifndef BRDFLIBRARY_INCULDE
#define BRDFLIBRARY_INCULDE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------- //
///////////////////////////////////////////////////////////////////////////////
//                                UE4 BRDF                                   //
///////////////////////////////////////////////////////////////////////////////
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------- //
inline float Pow2_UE4(float x)
{
    return x * x;
}

inline float Pow4_UE4(float x)
{
    float xx = x * x;
    return xx * xx;
}

inline float Pow5_UE4(float x)
{
    float xx = x * x;
    return xx * xx * x;
}

float3 Diffuse_Lambert(float3 DiffuseColor)
{
    return DiffuseColor * (1 / PI);
}

float D_GGX_UE4(float a2, float NoH)
{
    // 2 mad
    float d = (NoH * a2 - NoH) * NoH + 1.0;
    // 4 mul, 1 rcp
    return a2 / (PI * d * d);
}

float D_DistrubutionGGX(float3 N, float3 H, float a2, float Pi)
{
    float NH = max(0.0, dot(N, H));
    float NH2 = NH * NH;
    // 分子
    float nominator = a2;
    // 分母
    float denominator = (NH2 * (a2 - 1.0) + 1.0);
    denominator = Pi * denominator * denominator;
    //0.001是为了防止分母为0
    return nominator / max(denominator, 0.00001);
}

// use GGX / Trowbridge-Reitz, same as Disney and Unreal 4
float normal_distrib(float3 N, float3 H, float Roughness, float Pi)
{
    float NH = max(0.0, dot(N, H));
    float alpha = Roughness * Roughness;
    float tmp = alpha / max(1e-8, (NH * NH * (alpha * alpha - 1.0) + 1.0));

    return tmp * tmp * Pi;
}

// Appoximation of joint Smith term for GGX
// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
float Vis_SmithJointApprox(float a2, float NoV, float NoL)
{
    float a = sqrt(a2);
    float Vis_SmithV = NoL * (NoV * (1.0 - a) + a);
    float Vis_SmithL = NoV * (NoL * (1.0 - a) + a);
    return 0.5 * rcp(Vis_SmithV + Vis_SmithL);
}

// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
float3 F_Schlick_UE4(float3 SpecularColor, float VoH)
{
    float Fc = Pow5_UE4(1 - VoH);					// 1 sub, 3 mul
    //return Fc + (1 - Fc) * SpecularColor;		// 1 add, 3 mad
    // Anything less than 2% is physically impossible and is instead considered to be shadowing
    return saturate(50.0 * SpecularColor.g) * Fc + (1 - Fc) * SpecularColor;
}

float3 StandardDirectBRDF_UE4(float3 DiffuseColor, float3 SpecularColor, float Roughness, float3 N, float3 V, float3 L, float3 LightColor, float Shadow)
{
    float a2 = Pow4_UE4(Roughness);
    float3 H = normalize(L + V);
    float NoH = saturate(dot(N, H));
    float NoV = saturate(abs(dot(N, V)) + 1e-5);
    // Unity中使用 LoH 代替了 VoH
    float VoH = saturate(dot(V, H));
    float NoL = saturate(dot(N, L));
    float D = D_GGX_UE4(a2, NoH);
    float Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    float3 F = F_Schlick_UE4(SpecularColor, VoH);
    float3 radians = NoL * LightColor * Shadow;
    // --------
    // 漫反射项
    float3 diffuseTerm = Diffuse_Lambert(DiffuseColor) * radians;
    // 为了匹配unity的效果
    diffuseTerm *= PI;
    // ---------
    // 镜面反射项
    float3 specularTerm = (D * Vis) * F * radians;
    // 为了匹配unity的效果
    specularTerm *= PI;
    float3 directLighting = float3(0.0, 0.0, 0.0);
    #ifdef _LIGHTINGCHECK_DIRECTDIFFUSE
        directLighting = diffuseTerm;
    #elif _LIGHTINGCHECK_DIRECTSPECULAR
        directLighting = specularTerm;
    #elif _LIGHTINGCHECK_DIRECTLIGHTING
        directLighting = diffuseTerm + specularTerm;
    #elif _LIGHTINGCHECK_ALL
        directLighting = diffuseTerm + specularTerm;
    #endif
    return directLighting;
}

float3 StandardDirectBRDF_UE4_Water(float3 DiffuseColor, float3 SpecularColor, float Roughness, float3 N, float3 V, float3 L, float3 LightColor, float Shadow)
{
    float a2 = Pow4_UE4(Roughness);
    float3 H = normalize(L + V);
    float NoH = saturate(dot(N, H));
    float NoV = saturate(abs(dot(N, V)) + 1e-5);
    // Unity中使用 LoH 代替了 VoH
    float VoH = saturate(dot(V, H));
    float NoL = saturate(dot(N, L));
    float D = D_GGX_UE4(a2, NoH);
    float Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    float3 F = F_Schlick_UE4(SpecularColor, VoH);
    float3 radians = NoL * LightColor * Shadow;
    // --------
    // 漫反射项
    float3 diffuseTerm = Diffuse_Lambert(DiffuseColor) * radians;
    // 为了匹配unity的效果
    diffuseTerm *= PI;
    // ---------
    // 镜面反射项
    float3 specularTerm = (D * Vis) * F * radians;
    // 为了匹配unity的效果
    float3 directLighting = diffuseTerm + specularTerm;
    return directLighting;
}

float3 EnvBRDFApprox_UE4(float3 SpecularColor, float Roughness, float NoV)
{
    // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
    // Adaptation to fit our G term.
    const float4 c0 = {
        - 1, -0.0275, -0.572, 0.022
    };
    const float4 c1 = {
        1, 0.0425, 1.04, -0.04
    };
    float4 r = Roughness * c0 + c1;
    float a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
    float2 AB = float2(-1.04, 1.04) * a004 + r.zw;
    // Anything less than 2% is physically impossible and is instead considered to be shadowing
    // Note: this is needed for the 'specular' show flag to work, since it uses a SpecularColor of 0
    AB.y *= saturate(50.0 * SpecularColor.g);

    return SpecularColor * AB.x + AB.y;
}

float GetSpecularOcclusion(float NoV, float RoughnessSq, float AO)
{
    return saturate(pow(max(0.0, NoV + AO), RoughnessSq) - 1.0 + AO);
}

float3 AOMultiBounce(float3 BaseColor, float3 AO)
{
    float3 a = 2.0404 * BaseColor - float3(0.3324, 0.3324, 0.3324);
    float3 b = -4.7951 * BaseColor + float3(0.6417, 0.6417, 0.6417);
    float3 c = 2.7552 * BaseColor + float3(0.6903, 0.6903, 0.6903);
    return max(AO, ((AO * a + b) * AO + c) * AO);
}

float3 StandardIndirectBRDF_UE4(float3 DiffuseColor, float3 SpecularColor, float Roughness, float3 positionWS, float3 N, float3 V, float Occlusion)
{
    // ----------
    // SH内置 *PI
    float3 radiansSH = SampleSH(N);
    // --------------------
    // 进阶改造 AO，防止漏光
    float3 diffuseAO = AOMultiBounce(DiffuseColor, Occlusion);
    float3 indirectDiffuse = radiansSH * DiffuseColor * diffuseAO;
    // ---------------------
    // IBL[SplitSum - Part1]
    float3 rDir = normalize(reflect(-V, N));
    float3 specularLD = GlossyEnvironmentReflection(rDir, positionWS, Roughness, Occlusion);
    // -------------------------
    // 数值拟合[SplitSum - Part2]
    float NoV = saturate(abs(dot(N, V)) + 1e-5);
    float3 specularDFG = EnvBRDFApprox_UE4(SpecularColor, Roughness, NoV);
    // --------------------
    // 进阶改造 AO，防止漏光
    float3 specularOcclusion = GetSpecularOcclusion(NoV, Pow2_UE4(Roughness), Occlusion);
    float3 specularAO = AOMultiBounce(SpecularColor, specularOcclusion);
    // -------------
    // 计算间接光结果
    float3 indirectSpecular = specularLD * specularDFG * specularAO;
    // --------
    // 最终结果
    float3 indirectLighting = float3(0.0, 0.0, 0.0);
    #ifdef _LIGHTINGCHECK_INDIRECTDIFFUSE
        indirectLighting = indirectDiffuse;
    #elif _LIGHTINGCHECK_INDIRECTSPECULAR
        indirectLighting = indirectSpecular;
    #elif _LIGHTINGCHECK_INDIRECTLIGHTING
        indirectLighting = indirectDiffuse + indirectSpecular;
    #elif _LIGHTINGCHECK_ALL
        indirectLighting = indirectDiffuse + indirectSpecular;
    #endif
    return indirectLighting;
}

float3 StandardIndirectBRDF_UE4_Water(float3 DiffuseColor, float3 SpecularColor, float Roughness, float3 positionWS, float3 N, float3 V, float3 rDir)
{
    // ----------
    // SH内置 *PI
    float3 radiansSH = SampleSH(N);
    float3 indirectDiffuse = radiansSH * DiffuseColor;
    // ---------------------
    // IBL[SplitSum - Part1]
    // Planar Reflection
    // float2 uv_Planar = screenUV.xy + lerp(float2(0.0, 0.0), worldNormal.xz, _reflectionDisort);
    // float3 planarReflection = SAMPLE_TEXTURE2D_LOD(_PlanarReflectionTexture, sampler_PlanarReflectionTexture, uv_Planar, _reflectionBlur).xyz;
    float3 specularLD = GlossyEnvironmentReflection(rDir, positionWS, Roughness, 1);
    // -------------------------
    // 数值拟合[SplitSum - Part2]
    float NoV = saturate(abs(dot(N, V)) + 1e-5);
    float3 specularDFG = EnvBRDFApprox_UE4(SpecularColor, Roughness, NoV);
    // -------------
    // 计算间接光结果
    float3 indirectSpecular = specularLD * specularDFG;
    // float3 indirectSpecular = planarReflection * specularDFG;
    // --------
    // 最终结果
    float3 indirectLighting = indirectDiffuse + indirectSpecular;
    return indirectLighting;
}

#endif