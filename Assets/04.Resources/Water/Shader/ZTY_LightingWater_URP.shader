Shader "ZTY/LightingWater/URP"
{
    Properties
    {
        [Header(Surface Color _____________________________________________________________________________________________________________________________________________________________)]
        [Header((((Basecolor))))]
        [Space(10)]
        _shallowColor ("Shallow Color", Color) = (0.6, 0.8, 0.8, 0.0)
        _deepColor ("Deep Color", Color) = (0.1, 0.26, 0.3, 0.0)
        _deepRange ("Deep Range", Range(0.0, 10.0)) = 1.0
        _deepOpacity ("Deep Opacity", Range(0.0, 1.0)) = 0.95

        [Header((((Specular))))]
        [Space(10)]
        _specularColor ("Specular Color", Color) = (0.8, 0.9, 1.0, 0.0)
        _specularRadius ("Specular Radius", Range(1.0, 3.0)) = 1.6
        _specularIntensity ("Specular Intensity", Range(0.0, 3.0)) = 1.0
        
        [Header((((Planar Reflection))))]
        [Space(10)]
        _reflectionDisort ("Reflection Disort", Range(0.0, 1.0)) = 0.2
        _reflectionDisortFadeOut ("Reflection Disort Fade Out", Range(1.0, 10.0)) = 2.0
        _fresnelRange ("Fresnel Range", Range(1.0, 16.0)) = 6.0
        _fresnelIntensity ("Fresnel Intensity", Range(0.0, 3.0)) = 1.0
        [Header(___________________________________________________________________________________________________________________________________________________________________________)]

        [Header(Wave ______________________________________________________________________________________________________________________________________________________________________)]
        [Header((((Wave))))]
        [Space(10)]
        [Toggle(_WAVE)]_WAVE ("Wave On", int) = 1
        _waveDirection ("Wave Direction", vector) = (1.0, 1.0, 0.0, 0.0)
        _waveSpeed ("Wave Speed", float) = 2.0
        _waveScale ("Wave Scale", Range(0.0, 1.0)) = 0.9
        _waveHeight ("Wave Height", Range(-2.0, 10.0)) = 1.5
        _waveDetailScale ("Wave Detail Scale", vector) = (0.5, 0.5, 0.5, -1.0)
        _waveNormalStr ("wave Normal Str", float) = 5.0
        _waveFadeStart ("Wave Fade Start", float) = 5.0
        _waveFadeEnd ("Wave Fade End", float) = 150.0
        [Header((((Crest))))]
        [Space(10)]
        _waveCrestColor ("Crest Color", Color) = (0.2, 0.5, 0.5, 0.0)
        _crestRadius ("Crest Radius", Range(1.0, 4.0)) = 1.5
        _crestIntensity ("Crest Intensity", Range(0.0, 10.0)) = 4.0
        [Header(___________________________________________________________________________________________________________________________________________________________________________)]

        [Header(Ripple ____________________________________________________________________________________________________________________________________________________________________)]
        [Header((((Ripple))))]
        [Space(10)]
        [Toggle(_USERIPPLE)]_RIPPLEON ("Ripple On", int) = 1
        [Normal][NoScaleOffset] _ripple ("Ripple Map", 2D) = "bump" { }
        [Header((Tilling(XY) IntensityA(Z) IntensityB(W))]
        [Space(10)]
        _smallRippleParams ("Ripple Params", vector) = (0.03, 0.03, 1.0, 0.0)
        [Header((Center(XY) Angle(Z) Speed(W)))]
        [Space(10)]
        rippleDirectionA ("Ripple Direction And Speed A", vector) = (0.0, 0.0, 0.0, 0.1)
        rippleDirectionB ("Ripple Direction And Speed B", vector) = (0.0, 0.0, 0.0, 0.1)
        _rippleFadeOut ("Ripple Fade Out", Range(1.0, 10.0)) = 2.0

        [Header((((Detail))))]
        [Space(10)]
        [Toggle(_USEDETAILRIPPLE)]_DETAILRIPPLEON ("Detial On", int) = 0
        [Normal][NoScaleOffset] _detialRipple ("Detial Map", 2D) = "bump" { }
        [Header((Tilling(XY) IntensityA(Z) IntensityB(W)))]
        [Space(10)]
        _detialRippleParams ("Detial Params", vector) = (0.03, 0.03, 1.0, 0.07)
        [Header((Center(XY) Angle(Z) Speed(W)))]
        [Space(10)]
        _detialDirectionA ("Detial Direction And Speed A", vector) = (0.0, 0.0, 0.0, 0.1)
        _detialDirectionB ("Detial Direction And Speed B", vector) = (0.0, 0.0, 0.0, 0.1)
        [Header(___________________________________________________________________________________________________________________________________________________________________________)]

        // [Header(Foam ____________________________________________________________________________________________________________________________________________________________________)]
        // [Space(10)]
        // _foamColor ("Foam Color", Color) = (1.0, 1.0, 1.0, 0.0)
        // [NoScaleOffset] _foam ("Foam Map", 2D) = "black" { }
        // [Header((Tilling(XY) Intensity(Z) Speed(W)))]
        // [Space(10)]
        // _foamParams ("Foam Params", vector) = (0.03, 0.03, 1.0, 0.1)

        [Header(Under Water _______________________________________________________________________________________________________________________________________________________________)]
        [Header((((Refraction))))]
        [Space(10)]
        [Toggle(_USEREFRACTION)]_REFRACTIONON ("Refraction On", int) = 1
        _refractionIntensity ("Refraction Intensity", Range(0.0, 1.0)) = 0.5

        [Header((((Caustics))))]
        [Space(10)]
        [Toggle(_USECAUSTICS)]_CAUSTICSON ("Caustics On", int) = 1
        [NoScaleOffset] _causticsMap ("Caustics Map", 2D) = "white" { }
        [Header((Tilling(XY) Intensity(Z) Speed(W)))]
        [Space(10)]
        _causticsDisort ("Caustics Disort", Range(0.0, 3.0)) = 0.5
        _causticsParams ("Caustics Params", vector) = (0.05, 0.05, 0.3, 0.07)
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True" "ShaderModel" = "4.5"
        }
        Blend One Zero
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Name "Water"
            HLSLPROGRAM
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "./Input_Normal.hlsl"
            #include "./Input_Wave.hlsl"
            #include "./Input_Caustics.hlsl"
            #include "./Input_Refraction.hlsl"
            #include "./Input_Color.hlsl"
            // Keywords
            #pragma shader_feature_local _USECREST
            #pragma shader_feature_local _USERIPPLE
            #pragma shader_feature_local _USEDETAILRIPPLE
            #pragma shader_feature_local _WAVE
            #pragma shader_feature_local _USEREFRACTION
            #pragma shader_feature_local _USECAUSTICS
            #pragma exclude_renderers gles gles3 glcore
            #pragma enable_d3d11_debug_symbols

            struct Attributes
            {
                float4 pos_vertex : POSITION;
                float3 normal_vertex : NORMAL;
                float4 tangent_vertex : TANGENT;
            };

            struct Varyings
            {
                float4 pos_clip : SV_POSITION;
                float3 pos_view : TEXCOORD0;
                float3 pos_world : TEXCOORD1;
                float3 normal_world : TEXCOORD2;
                float4 tangent_world : TEXCOORD3;
                float3 bitangent_world : TEXCOORD4;
                float4 pos_object : TEXCOORD5;
                float3 pos_offset : TEXCOORD6;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _shallowColor, _deepColor, _specularColor, _waveCrestColor, _waveDirection, _waveDetailScale, _smallRippleParams, rippleDirectionA, rippleDirectionB,
                _detialRippleParams, _detialDirectionA, _detialDirectionB, _foamColor, _foamParams, _causticsParams;
                float _deepRange, _deepOpacity, _specularRadius, _specularIntensity, _reflectionDisort, _reflectionDisortFadeOut, _rippleFadeOut, _refractionIntensity, _underRange,
                _fresnelRange, _fresnelIntensity, _crestIntensity, _crestRadius, _waveSpeed, _waveScale, _waveHeight, _waveNormalStr, _waveFadeStart, _waveFadeEnd, _causticsDisort;
            CBUFFER_END
            TEXTURE2D(_causticsMap);                  SAMPLER(sampler_causticsMap);
            TEXTURE2D(_PlanarReflectionTexture);      SAMPLER(sampler_PlanarReflectionTexture);
            TEXTURE2D(_ripple);                       SAMPLER(sampler_ripple);
            TEXTURE2D(_detialRipple);                 SAMPLER(sampler_detialRipple);
            // TEXTURE2D(_foam);                         SAMPLER(sampler_foam);
            TEXTURE2D(_CameraDepthTexture);           SAMPLER(sampler_CameraDepthTexture);
            TEXTURE2D(_CameraOpaqueTexture);          SAMPLER(sampler_CameraOpaqueTexture);
            
            Varyings LitPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.pos_world = TransformObjectToWorld(input.pos_vertex.xyz);
                output.pos_view = TransformWorldToView(output.pos_world);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal_vertex, input.tangent_vertex);
                output.tangent_world.xyz = normalInput.tangentWS;
                output.bitangent_world = normalInput.bitangentWS;
                output.normal_world = normalInput.normalWS;
                output.pos_offset = float3(0, 0, 0);
                float3 normal_world2 = float3(0, 1, 0);
                #ifdef _WAVE
                    float2 speed_Wave = _Time.y * _waveSpeed * _waveDirection.xy;
                    GetWaveInfo(output.pos_world.xz, speed_Wave, _waveDetailScale, _waveScale, _waveHeight, _waveNormalStr, _waveFadeStart, _waveFadeEnd, output.pos_offset, normal_world2);
                #endif
                input.pos_vertex.xyz += output.pos_offset;
                output.pos_clip = TransformObjectToHClip(input.pos_vertex.xyz);
                return output;
            }

            float4 LitPassFragment(Varyings input) : SV_Target
            {
                //////////////////////////
                ///    Input Dates     ///
                //////////////////////////
                float3 worldNormal = input.normal_world;
                float3 worldPosition = input.pos_world;
                float3 cameraPosition = normalize(_WorldSpaceCameraPos.xyz - worldPosition);
                float4 screenPosition = input.pos_clip / _ScreenParams;
                Light light = GetMainLight();
                float3 light_Dir = light.direction;
                float3 light_Color = light.color;
                
                ///////////////////////
                //    Water alpha    //
                ///////////////////////
                // 采样原始深度图并计算水初始（无扭曲）的深度值
                float depthTexture = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, screenPosition.xy).x;
                float depthScene = LinearEyeDepth(depthTexture, _ZBufferParams);
                float depth_water = depthScene + input.pos_view.z;
                depth_water = (1.0 - saturate(exp( - (depth_water) / max(0.5, _deepRange)))) * _deepOpacity;

                ///////////////////////
                //    Water Wave     //
                ///////////////////////
                float3 wavePosition = input.pos_offset;
                #ifdef _WAVE
                    float2 speed_Wave = _Time.y * _waveSpeed * _waveDirection.xy;
                    GetWaveInfo(worldPosition.xz, speed_Wave, _waveDetailScale, _waveScale, _waveHeight, _waveNormalStr, _waveFadeStart, _waveFadeEnd, wavePosition, worldNormal);
                #endif

                ////////////////////////
                //    Water Ripple    //
                ////////////////////////
                float3x3 matrix_TBN = float3x3(input.tangent_world.xyz, input.bitangent_world, input.normal_world);
                float3 rippleNormal = float3(0.0, 0.0, 1.0);
                #ifdef _USERIPPLE
                    rippleNormal = GetRippleNormal(_ripple, sampler_ripple, worldPosition.xz, _smallRippleParams, rippleDirectionA, rippleDirectionB);
                #endif
                float3 detailrippleNormal = float3(0.0, 0.0, 1.0);
                #ifdef _USEDETAILRIPPLE
                    detailrippleNormal = GetRippleNormal(_detialRipple, sampler_detialRipple, worldPosition.xz, _detialRippleParams, _detialDirectionA, _detialDirectionB);
                #endif
                float3 normalBlendTS = NormalBlending_ReorientedNormalMapping(rippleNormal, detailrippleNormal);
                float3 normalBlendWS = normalize(mul(normalBlendTS, matrix_TBN));
                float fadeOutFactor = GetFresnelFactor(worldNormal, cameraPosition, _rippleFadeOut, 16.0);
                normalBlendWS = lerp(worldNormal, normalBlendWS, fadeOutFactor);
                float3 finalWorldNormal = normalize(normalBlendWS + worldNormal);
                finalWorldNormal = lerp(worldNormal, finalWorldNormal, depth_water);

                ///////////////////////
                //    Crest Color    //
                ///////////////////////
                float3 crestColor = 0;
                float ndotl = max(0.0, dot(finalWorldNormal, light_Dir));
                #ifdef _WAVE
                    float distortRange = GetFresnelFactor(finalWorldNormal, cameraPosition, _reflectionDisortFadeOut, 16.0);
                    finalWorldNormal = lerp(worldNormal, finalWorldNormal, distortRange);
                    float waveCrestMask = saturate(pow((1.0 - ndotl), _crestRadius * 2.0)) * max(0.0, _crestIntensity * wavePosition.y);
                    crestColor = _waveCrestColor.xyz * waveCrestMask;
                #endif
                
                //////////////////////
                //    Foam Color    //
                //////////////////////
                // float2 speed_Foam = _Time.y * _foamParams.w;
                // float foamMask = SAMPLE_TEXTURE2D(_foam, sampler_foam, _foamParams.xy * worldPosition.xz + speed_Foam).x;
                // foamMask = saturate(pow(foamMask, 8));
                // foamMask *= saturate(pow(wavePosition.y, 8) - 0.3);
                // float3 foamColor = foamMask * _foamColor.xyz;

                /////////////////////////////
                //    Planar Reflection    //
                /////////////////////////////
                float2 uv_Planar = screenPosition.xy + lerp(float2(0.0, 0.0), finalWorldNormal.xz, _reflectionDisort);
                float3 planarReflection = SAMPLE_TEXTURE2D(_PlanarReflectionTexture, sampler_PlanarReflectionTexture, uv_Planar).xyz;

                /////////////////////////////////////////////
                //    ReconstructWorldPositionfromDepth    //
                /////////////////////////////////////////////
                float4 depthToWorldPosition = ReconstructWorldPosition(_CameraDepthTexture, sampler_CameraDepthTexture, screenPosition.xy, input.pos_view);

                //////////////////////////
                //    Caustics Color    //
                //////////////////////////
                float3 color_caustics = 0.0;
                #ifdef _USECAUSTICS
                    color_caustics = GetCausticsColor(_causticsMap, sampler_causticsMap, depthToWorldPosition.xz, _causticsParams, finalWorldNormal.xz, _causticsDisort);
                #endif

                ////////////////////////////
                //    Refraction Color    //
                ////////////////////////////
                float2 refractionUV = screenPosition.xy;
                #ifdef _USEREFRACTION
                    refractionUV += finalWorldNormal.xz * _refractionIntensity * 0.1;
                #endif
                float3 color_Refraction = GetRefractionColor(refractionUV, _CameraDepthTexture, sampler_CameraDepthTexture, input.pos_view.z, _CameraOpaqueTexture, sampler_CameraOpaqueTexture, screenPosition.xy);


                /////////////////////////
                //    Water Specular   //
                /////////////////////////
                float3 specularColor = GetWaterSpecularColor(_specularColor.xyz, finalWorldNormal, _specularRadius, light_Dir, cameraPosition, light_Color);

                ///////////////////////
                //    Color Blend    //
                ///////////////////////
                float ndotv = saturate(dot(finalWorldNormal, cameraPosition));
                float fresnelFactor = saturate(pow(1.0 - ndotv, _fresnelRange) * _fresnelIntensity);
                
                float3 shallowAreaColor = color_Refraction * _shallowColor.xyz;
                float3 surfaceColor = lerp(_deepColor.xyz, planarReflection, fresnelFactor);
                float3 color_blend = lerp(_shallowColor.xyz * color_Refraction, _deepColor.xyz, depth_water) + planarReflection * fresnelFactor;
                #ifdef _WAVE
                    color_blend += crestColor;
                #endif
                color_blend += color_caustics * (1.0 - depth_water) * depth_water;
                color_blend *= light_Color * ndotl;
                color_blend += specularColor * _specularIntensity * depth_water * ndotl;

                ////////////////////////
                //    Final Output    //
                ////////////////////////
                return float4(color_blend, depth_water);
            }
            ENDHLSL
        }
    }
}