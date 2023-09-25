// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CartoonWater"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header((Color Settings))][Space(5)]_ShallowColor("浅水颜色", Color) = (0.4862745,1,0.8588235,0)
		_DeepColor("深水颜色", Color) = (0,0.4666667,0.7450981,0)
		_WaterDeep("水深浅范围", Float) = 5
		_FresnelColor("菲涅尔颜色", Color) = (0.3686275,0.6431373,0.9137255,0)
		_FresnelIntensity("菲涅尔强度", Float) = 0.2
		_ReflectionAngle("菲涅尔反射角度", Float) = 1
		[Toggle(_UNDERWATER_ON)] _UNDERWATER("水底图", Float) = 1
		_UnderWaterDistort("水底折射", Float) = 3
		_ShoreDistance("水透明范围", Float) = 1.5
		_Alpha("总体透明度控制", Float) = 1
		_DayIntensity("总体亮度控制", Float) = 0.75
		[Header((Water Normal))][Space(5)][KeywordEnum(LOW,MID,HIGH)] _WaterQuliaty("水动画质量", Float) = 2
		_WaterNormalSmall("细波纹法线", 2D) = "bump" {}
		_SmallNormalTiling("Small Normal Tiling", Float) = 10
		_SmallNormalSpeed("Small Normal Speed", Float) = 5
		_SmallNormalIntensity("Small Normal Intensity", Range( 0 , 1)) = 0.1
		_WaterNormalLarge("大波纹法线", 2D) = "bump" {}
		_LargeNormalTiling("Large Normal Tiling", Float) = 10
		_LargeNormalSpeed("Large Normal Speed", Float) = 5
		_LargeNormalIntensity("Large Normal Intensity", Range( 0 , 1)) = 0.1
		[Header((Reflection))][Space(5)]_ReflectCube("反射图", CUBE) = "white" {}
		_ReflectDistort("反射扭曲", Range( 0 , 1)) = 1
		_ReflectIntensity("反射强度", Float) = 1
		[Header((Caustics))][Space(5)][Toggle(_CAUSTICS_ON)] _Caustics("焦散动画", Float) = 1
		_CausticsTex("焦散图", 2D) = "white" {}
		_CausticsScale("焦散大小", Float) = 5
		_CausticsSpeed("焦散速度", Vector) = (-8,0,0,0)
		_CausticsIntensity("焦散亮度", Float) = 1
		[Header((Foam))][Space(5)][Toggle(_FOAM_ON)] _FOAM("岸边泡沫", Float) = 1
		[NoScaleOffset]_FoamNoise("泡沫Noise", 2D) = "white" {}
		_XTilling("泡沫TillingX", Float) = 10
		_YTilling("泡沫TillingY", Float) = 1
		_FoamNoiseSpeed("泡沫速度", Vector) = (0,-0.3,0,0)
		_FoamOffset("泡沫偏移", Float) = 0
		_FoamRange("泡沫范围", Float) = 1.5
		_FoamColor("泡沫颜色", Color) = (1,1,1,1)
		[Header(Sparkles)][Space(5)]_SparklesIntensity("波光亮度", Float) = 10
		_SparklesAmount("波光数量", Range( 0 , 1)) = 0.09
		[Header((Wave))][Space(5)][Toggle(_VERTEXWAVE_ON)] _VERTEXWAVE("顶点波纹动画", Float) = 1
		_Direction("水波运动方向（XY）", Vector) = (1,1,0,0)
		_WaveSpeed("水波速度", Float) = 2.4
		_WaveDistance("水波大小", Range( 0 , 1)) = 0.7
		_WaveHeight("水波高度", Float) = 0.15
		_SubWaveDirection("细节波形方向（XYZW）", Vector) = (-1,-1,-1,-1)
		_WaveNormalStr("水波法线强度", Float) = 0.16
		_WaveFadeStart("水波渐隐Start", Float) = 25
		_WaveFadeEnd("水波渐隐End", Float) = 280
		[HDR]_WaveColor("波峰颜色", Color) = (0.3686275,0.6431373,0.9137255,0)


		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector] _QueueControl("_QueueControl", Float) = -1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" "UniversalMaterialType"="Unlit" }

		Cull Back
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible

		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}

		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForwardOnly" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			

			HLSLPROGRAM

			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_OPAQUE_TEXTURE 1
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma instancing_options renderinglayer

			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        	#pragma multi_compile_fragment _ DEBUG_DISPLAY
        	#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        	#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_UNLIT

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _VERTEXWAVE_ON
			#pragma shader_feature_local_fragment _UNDERWATER_ON
			#pragma shader_feature_local_fragment _WATERQULIATY_LOW _WATERQULIATY_MID _WATERQULIATY_HIGH
			#pragma shader_feature_local_fragment _CAUSTICS_ON
			#pragma shader_feature_local_fragment _FOAM_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
					float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _WaveColor;
			float4 _SubWaveDirection;
			float4 _FresnelColor;
			float4 _DeepColor;
			float4 _ShallowColor;
			float4 _FoamColor;
			float2 _Direction;
			float2 _FoamNoiseSpeed;
			float2 _CausticsSpeed;
			float _ReflectIntensity;
			float _CausticsScale;
			float _CausticsIntensity;
			float _DayIntensity;
			float _SparklesIntensity;
			float _ReflectDistort;
			float _FoamOffset;
			float _FoamRange;
			float _XTilling;
			float _YTilling;
			float _SparklesAmount;
			float _WaveSpeed;
			float _ReflectionAngle;
			float _FresnelIntensity;
			float _ShoreDistance;
			float _UnderWaterDistort;
			float _LargeNormalIntensity;
			float _LargeNormalTiling;
			float _LargeNormalSpeed;
			float _SmallNormalIntensity;
			float _SmallNormalTiling;
			float _SmallNormalSpeed;
			float _WaveFadeEnd;
			float _WaveFadeStart;
			float _WaveNormalStr;
			float _WaveHeight;
			float _WaveDistance;
			float _WaterDeep;
			float _Alpha;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _WaterNormalSmall;
			sampler2D _WaterNormalLarge;
			uniform float4 _CameraDepthTexture_TexelSize;
			samplerCUBE _ReflectCube;
			sampler2D _CausticsTex;
			sampler2D _FoamNoise;


			float3 ReconstructWorldPos459( float2 ScreenUV, float rawdepth )
			{
				#if UNITY_REVERSED_Z
				real depth = rawdepth;
				#else
				real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, rawdepth);
				#endif
				float3 worldPos = ComputeWorldSpacePosition(ScreenUV, depth, UNITY_MATRIX_I_VP);
				return worldPos;
			}
			

			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float localGetWaveInfo571 = ( 0.0 );
				float2 position571 = (ase_worldPos).xz;
				float2 time571 = ( _WaveSpeed * _TimeParameters.x * _Direction );
				float4 directionABCD571 = _SubWaveDirection;
				float wavedistance571 = _WaveDistance;
				float height571 = _WaveHeight;
				float normalStr571 = _WaveNormalStr;
				float fadeStart571 = _WaveFadeStart;
				float fadeEnd571 = _WaveFadeEnd;
				float3 positionWSOffset571 = float3( 0,0,0 );
				float3 normalWS571 = float3( 0,0,0 );
				{
				 
				}
				float3 worldToObj583 = mul( GetWorldToObjectMatrix(), float4( ( ase_worldPos + positionWSOffset571 ), 1 ) ).xyz;
				#ifdef _VERTEXWAVE_ON
				float3 staticSwitch607 = worldToObj583;
				#else
				float3 staticSwitch607 = v.vertex.xyz;
				#endif
				float3 WaveVertexPos194 = staticSwitch607;
				
				float3 worldToObjDir584 = normalize( mul( GetWorldToObjectMatrix(), float4( normalWS571, 0 ) ).xyz );
				#ifdef _VERTEXWAVE_ON
				float3 staticSwitch611 = worldToObjDir584;
				#else
				float3 staticSwitch611 = v.ase_normal;
				#endif
				float3 WaveVertexNormal200 = staticSwitch611;
				
				float3 vertexToFrag652 = WaveVertexPos194;
				o.ase_texcoord3.xyz = vertexToFrag652;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord5.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord6.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord7.xyz = ase_worldBitangent;
				
				o.ase_texcoord4.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				o.ase_texcoord7.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = WaveVertexPos194;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = WaveVertexNormal200;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				#ifdef ASE_FOG
					o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif

				o.clipPos = positionCS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN
				#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
				#endif
				 ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float4 color621 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
				float3 vertexToFrag652 = IN.ase_texcoord3.xyz;
				float4 objectToClip8_g2 = TransformObjectToHClip(vertexToFrag652);
				float3 objectToClip8_g2NDC = objectToClip8_g2.xyz/objectToClip8_g2.w;
				float4 appendResult13_g2 = (float4(objectToClip8_g2NDC , 1.0));
				float4 computeScreenPos10_g2 = ComputeScreenPos( appendResult13_g2 );
				float4 ScreenPos649 = computeScreenPos10_g2;
				float temp_output_40_0 = ( _SmallNormalSpeed * _TimeParameters.x * 0.1 );
				float2 texCoord314 = IN.ase_texcoord4.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_315_0 = ( texCoord314 * _SmallNormalTiling );
				float2 panner316 = ( temp_output_40_0 * float2( 0.1,0.1 ) + temp_output_315_0);
				float3 tex2DNode43 = UnpackNormalScale( tex2D( _WaterNormalSmall, panner316 ), 1.0f );
				float2 panner318 = ( temp_output_40_0 * float2( -0.1,-0.1 ) + ( temp_output_315_0 + 0.4 ));
				float3 temp_output_52_0 = BlendNormal( tex2DNode43 , UnpackNormalScale( tex2D( _WaterNormalSmall, panner318 ), 1.0f ) );
				float2 panner321 = ( temp_output_40_0 * float2( -0.1,0.1 ) + ( temp_output_315_0 + float2( 0.85,0.15 ) ));
				float2 panner324 = ( temp_output_40_0 * float2( 0.1,-0.1 ) + ( temp_output_315_0 + float2( 0.65,0.75 ) ));
				#if defined(_WATERQULIATY_LOW)
				float3 staticSwitch630 = tex2DNode43;
				#elif defined(_WATERQULIATY_MID)
				float3 staticSwitch630 = temp_output_52_0;
				#elif defined(_WATERQULIATY_HIGH)
				float3 staticSwitch630 = BlendNormal( temp_output_52_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalSmall, panner321 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalSmall, panner324 ), 1.0f ) ) );
				#else
				float3 staticSwitch630 = BlendNormal( temp_output_52_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalSmall, panner321 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalSmall, panner324 ), 1.0f ) ) );
				#endif
				float3 lerpResult327 = lerp( float3(0,0,1) , staticSwitch630 , _SmallNormalIntensity);
				float3 SmallNormal44 = lerpResult327;
				float temp_output_333_0 = ( _LargeNormalSpeed * _TimeParameters.x * 0.1 );
				float2 texCoord340 = IN.ase_texcoord4.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_337_0 = ( texCoord340 * _LargeNormalTiling );
				float2 panner350 = ( temp_output_333_0 * float2( 0.1,0.1 ) + temp_output_337_0);
				float3 tex2DNode345 = UnpackNormalScale( tex2D( _WaterNormalLarge, panner350 ), 1.0f );
				float2 panner339 = ( temp_output_333_0 * float2( -0.1,-0.1 ) + ( temp_output_337_0 + 0.4 ));
				float3 temp_output_351_0 = BlendNormal( tex2DNode345 , UnpackNormalScale( tex2D( _WaterNormalLarge, panner339 ), 1.0f ) );
				float2 panner335 = ( temp_output_333_0 * float2( -0.1,0.1 ) + ( temp_output_337_0 + float2( 0.85,0.15 ) ));
				float2 panner338 = ( temp_output_333_0 * float2( 0.1,-0.1 ) + ( temp_output_337_0 + float2( 0.65,0.75 ) ));
				#if defined(_WATERQULIATY_LOW)
				float3 staticSwitch631 = tex2DNode345;
				#elif defined(_WATERQULIATY_MID)
				float3 staticSwitch631 = temp_output_351_0;
				#elif defined(_WATERQULIATY_HIGH)
				float3 staticSwitch631 = BlendNormal( temp_output_351_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalLarge, panner335 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalLarge, panner338 ), 1.0f ) ) );
				#else
				float3 staticSwitch631 = BlendNormal( temp_output_351_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalLarge, panner335 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalLarge, panner338 ), 1.0f ) ) );
				#endif
				float3 lerpResult357 = lerp( float3(0,0,1) , staticSwitch631 , _LargeNormalIntensity);
				float3 LargeNormal358 = lerpResult357;
				float3 normalizeResult366 = normalize( BlendNormal( SmallNormal44 , LargeNormal358 ) );
				float3 SurfaceNormal361 = normalizeResult366;
				float2 ScreenDistort432 = ( (SurfaceNormal361).xy * _UnderWaterDistort * 0.01 );
				float clampDepth471 = SHADERGRAPH_SAMPLE_SCENE_DEPTH( ( ScreenPos649 + float4( ScreenDistort432, 0.0 , 0.0 ) ).xy );
				float depthToLinear472 = LinearEyeDepth(clampDepth471,_ZBufferParams);
				float depthToLinear446 = LinearEyeDepth(IN.clipPos.z,_ZBufferParams);
				#ifdef _UNDERWATER_ON
				float staticSwitch622 = step( 0.0 , ( depthToLinear472 - depthToLinear446 ) );
				#else
				float staticSwitch622 = 0.0;
				#endif
				float RefractionMask449 = staticSwitch622;
				float2 lerpResult451 = lerp( float2( 0,0 ) , ScreenDistort432 , RefractionMask449);
				float4 fetchOpaqueVal70 = float4( SHADERGRAPH_SAMPLE_SCENE_COLOR( ( ScreenPos649 + float4( lerpResult451, 0.0 , 0.0 ) ).xy ), 1.0 );
				float4 SceneColor119 = fetchOpaqueVal70;
				#ifdef _UNDERWATER_ON
				float4 staticSwitch620 = SceneColor119;
				#else
				float4 staticSwitch620 = color621;
				#endif
				float4 UnderWaterColor78 = staticSwitch620;
				float3 ase_worldTangent = IN.ase_texcoord5.xyz;
				float3 ase_worldNormal = IN.ase_texcoord6.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord7.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal252 = SurfaceNormal361;
				float3 worldNormal252 = normalize( float3(dot(tanToWorld0,tanNormal252), dot(tanToWorld1,tanNormal252), dot(tanToWorld2,tanNormal252)) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult253 = dot( worldNormal252 , ase_worldViewDir );
				float temp_output_255_0 = ( 1.0 - max( dotResult253 , 0.0 ) );
				float lerpResult258 = lerp( 0.04 , 1.0 , ( temp_output_255_0 * temp_output_255_0 * temp_output_255_0 * temp_output_255_0 * temp_output_255_0 ));
				float temp_output_272_0 = pow( lerpResult258 , _ReflectionAngle );
				float temp_output_259_0 = ( temp_output_272_0 * _FresnelIntensity * 5.0 );
				float clampResult263 = clamp( ( temp_output_259_0 * temp_output_259_0 ) , 0.0 , 1.0 );
				float ColorFresnel485 = clampResult263;
				float4 lerpResult251 = lerp( _DeepColor , _FresnelColor , ColorFresnel485);
				float localGetWaveInfo571 = ( 0.0 );
				float2 position571 = (WorldPosition).xz;
				float2 time571 = ( _WaveSpeed * _TimeParameters.x * _Direction );
				float4 directionABCD571 = _SubWaveDirection;
				float wavedistance571 = _WaveDistance;
				float height571 = _WaveHeight;
				float normalStr571 = _WaveNormalStr;
				float fadeStart571 = _WaveFadeStart;
				float fadeEnd571 = _WaveFadeEnd;
				float3 positionWSOffset571 = float3( 0,0,0 );
				float3 normalWS571 = float3( 0,0,0 );
				{
				 
				}
				#ifdef _VERTEXWAVE_ON
				float staticSwitch609 = (positionWSOffset571).y;
				#else
				float staticSwitch609 = 0.0;
				#endif
				float WaveY594 = staticSwitch609;
				float clampResult598 = clamp( WaveY594 , 0.0 , 1.0 );
				float4 lerpResult596 = lerp( lerpResult251 , _WaveColor , clampResult598);
				float FresnelFactor547 = lerpResult258;
				float clampDepth465 = SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPos649.xy );
				float depthToLinear469 = LinearEyeDepth(clampDepth465,_ZBufferParams);
				float depthToLinear423 = LinearEyeDepth(ScreenPos649.z,_ZBufferParams);
				float WaterDepth2492 = ( depthToLinear469 - depthToLinear423 );
				float clampResult437 = clamp( ( WaterDepth2492 / _WaterDeep ) , 0.0 , 1.0 );
				float clampResult268 = clamp( max( FresnelFactor547 , ( FresnelFactor547 + clampResult437 ) ) , 0.0 , 1.0 );
				float4 lerpResult13 = lerp( ( _ShallowColor * UnderWaterColor78 ) , lerpResult596 , clampResult268);
				float4 WaterColor24 = lerpResult13;
				float3 lerpResult217 = lerp( float3(0,0,1) , SurfaceNormal361 , _ReflectDistort);
				float3 worldRefl236 = reflect( -ase_worldViewDir, float3( dot( tanToWorld0, lerpResult217 ), dot( tanToWorld1, lerpResult217 ), dot( tanToWorld2, lerpResult217 ) ) );
				float clampResult481 = clamp( temp_output_272_0 , 0.0 , 1.0 );
				float ReflectFresnel487 = clampResult481;
				float4 ReflectColor65 = ( texCUBE( _ReflectCube, worldRefl236 ) * _ReflectIntensity * ReflectFresnel487 );
				float4 color619 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
				float2 ScreenUV459 = ScreenPos649.xy;
				float rawdepth459 = clampDepth465;
				float3 localReconstructWorldPos459 = ReconstructWorldPos459( ScreenUV459 , rawdepth459 );
				float3 UnderWaterPos468 = localReconstructWorldPos459;
				float2 temp_output_91_0 = ( (UnderWaterPos468).xz / _CausticsScale );
				float2 temp_output_95_0 = ( _CausticsSpeed * _TimeParameters.x * 0.01 );
				float WaterDepthRange545 = clampResult268;
				#ifdef _CAUSTICS_ON
				float4 staticSwitch618 = ( ( min( tex2D( _CausticsTex, ( temp_output_91_0 + temp_output_95_0 ) ) , tex2D( _CausticsTex, ( -temp_output_91_0 + temp_output_95_0 ) ) ) * _CausticsIntensity ) * ( 1.0 - WaterDepthRange545 ) );
				#else
				float4 staticSwitch618 = color619;
				#endif
				float4 CausticsColor101 = staticSwitch618;
				float Splakes537 = ( step( _SparklesAmount , (SurfaceNormal361).y ) * _SparklesIntensity );
				float temp_output_478_0 = ( WaterDepth2492 / _FoamRange );
				float clampResult149 = clamp( ( _FoamOffset + temp_output_478_0 ) , 0.0 , 1.0 );
				float temp_output_150_0 = ( 1.0 - clampResult149 );
				float2 texCoord371 = IN.ase_texcoord4.xyz.xy * float2( 1,1 ) + float2( 0,0 );
				float clampResult479 = clamp( temp_output_478_0 , 0.0 , 1.0 );
				float2 appendResult384 = (float2(( _XTilling * texCoord371.x ) , ( clampResult479 * _YTilling )));
				float2 panner382 = ( 1.0 * _Time.y * _FoamNoiseSpeed + appendResult384);
				#ifdef _FOAM_ON
				float staticSwitch624 = step( 0.0 , ( depthToLinear469 - depthToLinear446 ) );
				#else
				float staticSwitch624 = 0.0;
				#endif
				float FoamMask567 = staticSwitch624;
				float clampResult411 = clamp( ( ( temp_output_150_0 - -1.0 ) * step( tex2D( _FoamNoise, panner382 ).r , temp_output_150_0 ) * FoamMask567 ) , 0.0 , 1.0 );
				#ifdef _FOAM_ON
				float4 staticSwitch615 = ( clampResult411 * _FoamColor * 2.0 );
				#else
				float4 staticSwitch615 = _FoamColor;
				#endif
				float4 FoamColor407 = staticSwitch615;
				#ifdef _FOAM_ON
				float staticSwitch614 = clampResult411;
				#else
				float staticSwitch614 = 0.0;
				#endif
				float Foam179 = staticSwitch614;
				float4 lerpResult408 = lerp( ( ( WaterColor24 + ReflectColor65 + CausticsColor101 + Splakes537 ) * _DayIntensity ) , FoamColor407 , Foam179);
				
				float clampResult291 = clamp( ( WaterDepth2492 / _ShoreDistance ) , 0.0 , 1.0 );
				float WaterOpacity27 = clampResult291;
				float clampResult504 = clamp( max( max( Foam179 , ReflectFresnel487 ) , (CausticsColor101).r ) , 0.0 , 1.0 );
				float lerpResult414 = lerp( WaterOpacity27 , 1.0 , clampResult504);
				float clampResult627 = clamp( ( lerpResult414 * _Alpha ) , 0.0 , 1.0 );
				float FinalAlpha497 = clampResult627;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult408.rgb;
				float Alpha = FinalAlpha497;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4( EncodeMeshRenderingLayer( renderingLayers ), 0, 0, 0 );
				#endif

				return half4( Color, Alpha );
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _VERTEXWAVE_ON
			#pragma shader_feature_local_fragment _FOAM_ON
			#pragma shader_feature_local_fragment _WATERQULIATY_LOW _WATERQULIATY_MID _WATERQULIATY_HIGH
			#pragma shader_feature_local_fragment _CAUSTICS_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _WaveColor;
			float4 _SubWaveDirection;
			float4 _FresnelColor;
			float4 _DeepColor;
			float4 _ShallowColor;
			float4 _FoamColor;
			float2 _Direction;
			float2 _FoamNoiseSpeed;
			float2 _CausticsSpeed;
			float _ReflectIntensity;
			float _CausticsScale;
			float _CausticsIntensity;
			float _DayIntensity;
			float _SparklesIntensity;
			float _ReflectDistort;
			float _FoamOffset;
			float _FoamRange;
			float _XTilling;
			float _YTilling;
			float _SparklesAmount;
			float _WaveSpeed;
			float _ReflectionAngle;
			float _FresnelIntensity;
			float _ShoreDistance;
			float _UnderWaterDistort;
			float _LargeNormalIntensity;
			float _LargeNormalTiling;
			float _LargeNormalSpeed;
			float _SmallNormalIntensity;
			float _SmallNormalTiling;
			float _SmallNormalSpeed;
			float _WaveFadeEnd;
			float _WaveFadeStart;
			float _WaveNormalStr;
			float _WaveHeight;
			float _WaveDistance;
			float _WaterDeep;
			float _Alpha;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _FoamNoise;
			sampler2D _WaterNormalSmall;
			sampler2D _WaterNormalLarge;
			sampler2D _CausticsTex;


			float3 ReconstructWorldPos459( float2 ScreenUV, float rawdepth )
			{
				#if UNITY_REVERSED_Z
				real depth = rawdepth;
				#else
				real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, rawdepth);
				#endif
				float3 worldPos = ComputeWorldSpacePosition(ScreenUV, depth, UNITY_MATRIX_I_VP);
				return worldPos;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float localGetWaveInfo571 = ( 0.0 );
				float2 position571 = (ase_worldPos).xz;
				float2 time571 = ( _WaveSpeed * _TimeParameters.x * _Direction );
				float4 directionABCD571 = _SubWaveDirection;
				float wavedistance571 = _WaveDistance;
				float height571 = _WaveHeight;
				float normalStr571 = _WaveNormalStr;
				float fadeStart571 = _WaveFadeStart;
				float fadeEnd571 = _WaveFadeEnd;
				float3 positionWSOffset571 = float3( 0,0,0 );
				float3 normalWS571 = float3( 0,0,0 );
				{
				 
				}
				float3 worldToObj583 = mul( GetWorldToObjectMatrix(), float4( ( ase_worldPos + positionWSOffset571 ), 1 ) ).xyz;
				#ifdef _VERTEXWAVE_ON
				float3 staticSwitch607 = worldToObj583;
				#else
				float3 staticSwitch607 = v.vertex.xyz;
				#endif
				float3 WaveVertexPos194 = staticSwitch607;
				
				float3 worldToObjDir584 = normalize( mul( GetWorldToObjectMatrix(), float4( normalWS571, 0 ) ).xyz );
				#ifdef _VERTEXWAVE_ON
				float3 staticSwitch611 = worldToObjDir584;
				#else
				float3 staticSwitch611 = v.ase_normal;
				#endif
				float3 WaveVertexNormal200 = staticSwitch611;
				
				float3 vertexToFrag652 = WaveVertexPos194;
				o.ase_texcoord2.xyz = vertexToFrag652;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = WaveVertexPos194;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = WaveVertexNormal200;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					float3 WorldPosition = IN.worldPos;
				#endif

				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float3 vertexToFrag652 = IN.ase_texcoord2.xyz;
				float4 objectToClip8_g2 = TransformObjectToHClip(vertexToFrag652);
				float3 objectToClip8_g2NDC = objectToClip8_g2.xyz/objectToClip8_g2.w;
				float4 appendResult13_g2 = (float4(objectToClip8_g2NDC , 1.0));
				float4 computeScreenPos10_g2 = ComputeScreenPos( appendResult13_g2 );
				float4 ScreenPos649 = computeScreenPos10_g2;
				float clampDepth465 = SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPos649.xy );
				float depthToLinear469 = LinearEyeDepth(clampDepth465,_ZBufferParams);
				float depthToLinear423 = LinearEyeDepth(ScreenPos649.z,_ZBufferParams);
				float WaterDepth2492 = ( depthToLinear469 - depthToLinear423 );
				float clampResult291 = clamp( ( WaterDepth2492 / _ShoreDistance ) , 0.0 , 1.0 );
				float WaterOpacity27 = clampResult291;
				float temp_output_478_0 = ( WaterDepth2492 / _FoamRange );
				float clampResult149 = clamp( ( _FoamOffset + temp_output_478_0 ) , 0.0 , 1.0 );
				float temp_output_150_0 = ( 1.0 - clampResult149 );
				float2 texCoord371 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float clampResult479 = clamp( temp_output_478_0 , 0.0 , 1.0 );
				float2 appendResult384 = (float2(( _XTilling * texCoord371.x ) , ( clampResult479 * _YTilling )));
				float2 panner382 = ( 1.0 * _Time.y * _FoamNoiseSpeed + appendResult384);
				float depthToLinear446 = LinearEyeDepth((0),_ZBufferParams);
				#ifdef _FOAM_ON
				float staticSwitch624 = step( 0.0 , ( depthToLinear469 - depthToLinear446 ) );
				#else
				float staticSwitch624 = 0.0;
				#endif
				float FoamMask567 = staticSwitch624;
				float clampResult411 = clamp( ( ( temp_output_150_0 - -1.0 ) * step( tex2D( _FoamNoise, panner382 ).r , temp_output_150_0 ) * FoamMask567 ) , 0.0 , 1.0 );
				#ifdef _FOAM_ON
				float staticSwitch614 = clampResult411;
				#else
				float staticSwitch614 = 0.0;
				#endif
				float Foam179 = staticSwitch614;
				float temp_output_40_0 = ( _SmallNormalSpeed * _TimeParameters.x * 0.1 );
				float2 texCoord314 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_315_0 = ( texCoord314 * _SmallNormalTiling );
				float2 panner316 = ( temp_output_40_0 * float2( 0.1,0.1 ) + temp_output_315_0);
				float3 tex2DNode43 = UnpackNormalScale( tex2D( _WaterNormalSmall, panner316 ), 1.0f );
				float2 panner318 = ( temp_output_40_0 * float2( -0.1,-0.1 ) + ( temp_output_315_0 + 0.4 ));
				float3 temp_output_52_0 = BlendNormal( tex2DNode43 , UnpackNormalScale( tex2D( _WaterNormalSmall, panner318 ), 1.0f ) );
				float2 panner321 = ( temp_output_40_0 * float2( -0.1,0.1 ) + ( temp_output_315_0 + float2( 0.85,0.15 ) ));
				float2 panner324 = ( temp_output_40_0 * float2( 0.1,-0.1 ) + ( temp_output_315_0 + float2( 0.65,0.75 ) ));
				#if defined(_WATERQULIATY_LOW)
				float3 staticSwitch630 = tex2DNode43;
				#elif defined(_WATERQULIATY_MID)
				float3 staticSwitch630 = temp_output_52_0;
				#elif defined(_WATERQULIATY_HIGH)
				float3 staticSwitch630 = BlendNormal( temp_output_52_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalSmall, panner321 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalSmall, panner324 ), 1.0f ) ) );
				#else
				float3 staticSwitch630 = BlendNormal( temp_output_52_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalSmall, panner321 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalSmall, panner324 ), 1.0f ) ) );
				#endif
				float3 lerpResult327 = lerp( float3(0,0,1) , staticSwitch630 , _SmallNormalIntensity);
				float3 SmallNormal44 = lerpResult327;
				float temp_output_333_0 = ( _LargeNormalSpeed * _TimeParameters.x * 0.1 );
				float2 texCoord340 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_337_0 = ( texCoord340 * _LargeNormalTiling );
				float2 panner350 = ( temp_output_333_0 * float2( 0.1,0.1 ) + temp_output_337_0);
				float3 tex2DNode345 = UnpackNormalScale( tex2D( _WaterNormalLarge, panner350 ), 1.0f );
				float2 panner339 = ( temp_output_333_0 * float2( -0.1,-0.1 ) + ( temp_output_337_0 + 0.4 ));
				float3 temp_output_351_0 = BlendNormal( tex2DNode345 , UnpackNormalScale( tex2D( _WaterNormalLarge, panner339 ), 1.0f ) );
				float2 panner335 = ( temp_output_333_0 * float2( -0.1,0.1 ) + ( temp_output_337_0 + float2( 0.85,0.15 ) ));
				float2 panner338 = ( temp_output_333_0 * float2( 0.1,-0.1 ) + ( temp_output_337_0 + float2( 0.65,0.75 ) ));
				#if defined(_WATERQULIATY_LOW)
				float3 staticSwitch631 = tex2DNode345;
				#elif defined(_WATERQULIATY_MID)
				float3 staticSwitch631 = temp_output_351_0;
				#elif defined(_WATERQULIATY_HIGH)
				float3 staticSwitch631 = BlendNormal( temp_output_351_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalLarge, panner335 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalLarge, panner338 ), 1.0f ) ) );
				#else
				float3 staticSwitch631 = BlendNormal( temp_output_351_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalLarge, panner335 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalLarge, panner338 ), 1.0f ) ) );
				#endif
				float3 lerpResult357 = lerp( float3(0,0,1) , staticSwitch631 , _LargeNormalIntensity);
				float3 LargeNormal358 = lerpResult357;
				float3 normalizeResult366 = normalize( BlendNormal( SmallNormal44 , LargeNormal358 ) );
				float3 SurfaceNormal361 = normalizeResult366;
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal252 = SurfaceNormal361;
				float3 worldNormal252 = normalize( float3(dot(tanToWorld0,tanNormal252), dot(tanToWorld1,tanNormal252), dot(tanToWorld2,tanNormal252)) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult253 = dot( worldNormal252 , ase_worldViewDir );
				float temp_output_255_0 = ( 1.0 - max( dotResult253 , 0.0 ) );
				float lerpResult258 = lerp( 0.04 , 1.0 , ( temp_output_255_0 * temp_output_255_0 * temp_output_255_0 * temp_output_255_0 * temp_output_255_0 ));
				float temp_output_272_0 = pow( lerpResult258 , _ReflectionAngle );
				float clampResult481 = clamp( temp_output_272_0 , 0.0 , 1.0 );
				float ReflectFresnel487 = clampResult481;
				float4 color619 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
				float2 ScreenUV459 = ScreenPos649.xy;
				float rawdepth459 = clampDepth465;
				float3 localReconstructWorldPos459 = ReconstructWorldPos459( ScreenUV459 , rawdepth459 );
				float3 UnderWaterPos468 = localReconstructWorldPos459;
				float2 temp_output_91_0 = ( (UnderWaterPos468).xz / _CausticsScale );
				float2 temp_output_95_0 = ( _CausticsSpeed * _TimeParameters.x * 0.01 );
				float FresnelFactor547 = lerpResult258;
				float clampResult437 = clamp( ( WaterDepth2492 / _WaterDeep ) , 0.0 , 1.0 );
				float clampResult268 = clamp( max( FresnelFactor547 , ( FresnelFactor547 + clampResult437 ) ) , 0.0 , 1.0 );
				float WaterDepthRange545 = clampResult268;
				#ifdef _CAUSTICS_ON
				float4 staticSwitch618 = ( ( min( tex2D( _CausticsTex, ( temp_output_91_0 + temp_output_95_0 ) ) , tex2D( _CausticsTex, ( -temp_output_91_0 + temp_output_95_0 ) ) ) * _CausticsIntensity ) * ( 1.0 - WaterDepthRange545 ) );
				#else
				float4 staticSwitch618 = color619;
				#endif
				float4 CausticsColor101 = staticSwitch618;
				float clampResult504 = clamp( max( max( Foam179 , ReflectFresnel487 ) , (CausticsColor101).r ) , 0.0 , 1.0 );
				float lerpResult414 = lerp( WaterOpacity27 , 1.0 , clampResult504);
				float clampResult627 = clamp( ( lerpResult414 * _Alpha ) , 0.0 , 1.0 );
				float FinalAlpha497 = clampResult627;
				

				float Alpha = FinalAlpha497;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }

			Cull Off

			HLSLPROGRAM

			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _VERTEXWAVE_ON
			#pragma shader_feature_local_fragment _FOAM_ON
			#pragma shader_feature_local_fragment _WATERQULIATY_LOW _WATERQULIATY_MID _WATERQULIATY_HIGH
			#pragma shader_feature_local_fragment _CAUSTICS_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _WaveColor;
			float4 _SubWaveDirection;
			float4 _FresnelColor;
			float4 _DeepColor;
			float4 _ShallowColor;
			float4 _FoamColor;
			float2 _Direction;
			float2 _FoamNoiseSpeed;
			float2 _CausticsSpeed;
			float _ReflectIntensity;
			float _CausticsScale;
			float _CausticsIntensity;
			float _DayIntensity;
			float _SparklesIntensity;
			float _ReflectDistort;
			float _FoamOffset;
			float _FoamRange;
			float _XTilling;
			float _YTilling;
			float _SparklesAmount;
			float _WaveSpeed;
			float _ReflectionAngle;
			float _FresnelIntensity;
			float _ShoreDistance;
			float _UnderWaterDistort;
			float _LargeNormalIntensity;
			float _LargeNormalTiling;
			float _LargeNormalSpeed;
			float _SmallNormalIntensity;
			float _SmallNormalTiling;
			float _SmallNormalSpeed;
			float _WaveFadeEnd;
			float _WaveFadeStart;
			float _WaveNormalStr;
			float _WaveHeight;
			float _WaveDistance;
			float _WaterDeep;
			float _Alpha;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _FoamNoise;
			sampler2D _WaterNormalSmall;
			sampler2D _WaterNormalLarge;
			sampler2D _CausticsTex;


			float3 ReconstructWorldPos459( float2 ScreenUV, float rawdepth )
			{
				#if UNITY_REVERSED_Z
				real depth = rawdepth;
				#else
				real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, rawdepth);
				#endif
				float3 worldPos = ComputeWorldSpacePosition(ScreenUV, depth, UNITY_MATRIX_I_VP);
				return worldPos;
			}
			

			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float localGetWaveInfo571 = ( 0.0 );
				float2 position571 = (ase_worldPos).xz;
				float2 time571 = ( _WaveSpeed * _TimeParameters.x * _Direction );
				float4 directionABCD571 = _SubWaveDirection;
				float wavedistance571 = _WaveDistance;
				float height571 = _WaveHeight;
				float normalStr571 = _WaveNormalStr;
				float fadeStart571 = _WaveFadeStart;
				float fadeEnd571 = _WaveFadeEnd;
				float3 positionWSOffset571 = float3( 0,0,0 );
				float3 normalWS571 = float3( 0,0,0 );
				{
				 
				}
				float3 worldToObj583 = mul( GetWorldToObjectMatrix(), float4( ( ase_worldPos + positionWSOffset571 ), 1 ) ).xyz;
				#ifdef _VERTEXWAVE_ON
				float3 staticSwitch607 = worldToObj583;
				#else
				float3 staticSwitch607 = v.vertex.xyz;
				#endif
				float3 WaveVertexPos194 = staticSwitch607;
				
				float3 worldToObjDir584 = normalize( mul( GetWorldToObjectMatrix(), float4( normalWS571, 0 ) ).xyz );
				#ifdef _VERTEXWAVE_ON
				float3 staticSwitch611 = worldToObjDir584;
				#else
				float3 staticSwitch611 = v.ase_normal;
				#endif
				float3 WaveVertexNormal200 = staticSwitch611;
				
				float3 vertexToFrag652 = WaveVertexPos194;
				o.ase_texcoord.xyz = vertexToFrag652;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				o.ase_texcoord5.xyz = ase_worldPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = WaveVertexPos194;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = WaveVertexNormal200;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float3 vertexToFrag652 = IN.ase_texcoord.xyz;
				float4 objectToClip8_g2 = TransformObjectToHClip(vertexToFrag652);
				float3 objectToClip8_g2NDC = objectToClip8_g2.xyz/objectToClip8_g2.w;
				float4 appendResult13_g2 = (float4(objectToClip8_g2NDC , 1.0));
				float4 computeScreenPos10_g2 = ComputeScreenPos( appendResult13_g2 );
				float4 ScreenPos649 = computeScreenPos10_g2;
				float clampDepth465 = SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPos649.xy );
				float depthToLinear469 = LinearEyeDepth(clampDepth465,_ZBufferParams);
				float depthToLinear423 = LinearEyeDepth(ScreenPos649.z,_ZBufferParams);
				float WaterDepth2492 = ( depthToLinear469 - depthToLinear423 );
				float clampResult291 = clamp( ( WaterDepth2492 / _ShoreDistance ) , 0.0 , 1.0 );
				float WaterOpacity27 = clampResult291;
				float temp_output_478_0 = ( WaterDepth2492 / _FoamRange );
				float clampResult149 = clamp( ( _FoamOffset + temp_output_478_0 ) , 0.0 , 1.0 );
				float temp_output_150_0 = ( 1.0 - clampResult149 );
				float2 texCoord371 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float clampResult479 = clamp( temp_output_478_0 , 0.0 , 1.0 );
				float2 appendResult384 = (float2(( _XTilling * texCoord371.x ) , ( clampResult479 * _YTilling )));
				float2 panner382 = ( 1.0 * _Time.y * _FoamNoiseSpeed + appendResult384);
				float depthToLinear446 = LinearEyeDepth((0),_ZBufferParams);
				#ifdef _FOAM_ON
				float staticSwitch624 = step( 0.0 , ( depthToLinear469 - depthToLinear446 ) );
				#else
				float staticSwitch624 = 0.0;
				#endif
				float FoamMask567 = staticSwitch624;
				float clampResult411 = clamp( ( ( temp_output_150_0 - -1.0 ) * step( tex2D( _FoamNoise, panner382 ).r , temp_output_150_0 ) * FoamMask567 ) , 0.0 , 1.0 );
				#ifdef _FOAM_ON
				float staticSwitch614 = clampResult411;
				#else
				float staticSwitch614 = 0.0;
				#endif
				float Foam179 = staticSwitch614;
				float temp_output_40_0 = ( _SmallNormalSpeed * _TimeParameters.x * 0.1 );
				float2 texCoord314 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_315_0 = ( texCoord314 * _SmallNormalTiling );
				float2 panner316 = ( temp_output_40_0 * float2( 0.1,0.1 ) + temp_output_315_0);
				float3 tex2DNode43 = UnpackNormalScale( tex2D( _WaterNormalSmall, panner316 ), 1.0f );
				float2 panner318 = ( temp_output_40_0 * float2( -0.1,-0.1 ) + ( temp_output_315_0 + 0.4 ));
				float3 temp_output_52_0 = BlendNormal( tex2DNode43 , UnpackNormalScale( tex2D( _WaterNormalSmall, panner318 ), 1.0f ) );
				float2 panner321 = ( temp_output_40_0 * float2( -0.1,0.1 ) + ( temp_output_315_0 + float2( 0.85,0.15 ) ));
				float2 panner324 = ( temp_output_40_0 * float2( 0.1,-0.1 ) + ( temp_output_315_0 + float2( 0.65,0.75 ) ));
				#if defined(_WATERQULIATY_LOW)
				float3 staticSwitch630 = tex2DNode43;
				#elif defined(_WATERQULIATY_MID)
				float3 staticSwitch630 = temp_output_52_0;
				#elif defined(_WATERQULIATY_HIGH)
				float3 staticSwitch630 = BlendNormal( temp_output_52_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalSmall, panner321 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalSmall, panner324 ), 1.0f ) ) );
				#else
				float3 staticSwitch630 = BlendNormal( temp_output_52_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalSmall, panner321 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalSmall, panner324 ), 1.0f ) ) );
				#endif
				float3 lerpResult327 = lerp( float3(0,0,1) , staticSwitch630 , _SmallNormalIntensity);
				float3 SmallNormal44 = lerpResult327;
				float temp_output_333_0 = ( _LargeNormalSpeed * _TimeParameters.x * 0.1 );
				float2 texCoord340 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_337_0 = ( texCoord340 * _LargeNormalTiling );
				float2 panner350 = ( temp_output_333_0 * float2( 0.1,0.1 ) + temp_output_337_0);
				float3 tex2DNode345 = UnpackNormalScale( tex2D( _WaterNormalLarge, panner350 ), 1.0f );
				float2 panner339 = ( temp_output_333_0 * float2( -0.1,-0.1 ) + ( temp_output_337_0 + 0.4 ));
				float3 temp_output_351_0 = BlendNormal( tex2DNode345 , UnpackNormalScale( tex2D( _WaterNormalLarge, panner339 ), 1.0f ) );
				float2 panner335 = ( temp_output_333_0 * float2( -0.1,0.1 ) + ( temp_output_337_0 + float2( 0.85,0.15 ) ));
				float2 panner338 = ( temp_output_333_0 * float2( 0.1,-0.1 ) + ( temp_output_337_0 + float2( 0.65,0.75 ) ));
				#if defined(_WATERQULIATY_LOW)
				float3 staticSwitch631 = tex2DNode345;
				#elif defined(_WATERQULIATY_MID)
				float3 staticSwitch631 = temp_output_351_0;
				#elif defined(_WATERQULIATY_HIGH)
				float3 staticSwitch631 = BlendNormal( temp_output_351_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalLarge, panner335 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalLarge, panner338 ), 1.0f ) ) );
				#else
				float3 staticSwitch631 = BlendNormal( temp_output_351_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalLarge, panner335 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalLarge, panner338 ), 1.0f ) ) );
				#endif
				float3 lerpResult357 = lerp( float3(0,0,1) , staticSwitch631 , _LargeNormalIntensity);
				float3 LargeNormal358 = lerpResult357;
				float3 normalizeResult366 = normalize( BlendNormal( SmallNormal44 , LargeNormal358 ) );
				float3 SurfaceNormal361 = normalizeResult366;
				float3 ase_worldTangent = IN.ase_texcoord2.xyz;
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal252 = SurfaceNormal361;
				float3 worldNormal252 = normalize( float3(dot(tanToWorld0,tanNormal252), dot(tanToWorld1,tanNormal252), dot(tanToWorld2,tanNormal252)) );
				float3 ase_worldPos = IN.ase_texcoord5.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult253 = dot( worldNormal252 , ase_worldViewDir );
				float temp_output_255_0 = ( 1.0 - max( dotResult253 , 0.0 ) );
				float lerpResult258 = lerp( 0.04 , 1.0 , ( temp_output_255_0 * temp_output_255_0 * temp_output_255_0 * temp_output_255_0 * temp_output_255_0 ));
				float temp_output_272_0 = pow( lerpResult258 , _ReflectionAngle );
				float clampResult481 = clamp( temp_output_272_0 , 0.0 , 1.0 );
				float ReflectFresnel487 = clampResult481;
				float4 color619 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
				float2 ScreenUV459 = ScreenPos649.xy;
				float rawdepth459 = clampDepth465;
				float3 localReconstructWorldPos459 = ReconstructWorldPos459( ScreenUV459 , rawdepth459 );
				float3 UnderWaterPos468 = localReconstructWorldPos459;
				float2 temp_output_91_0 = ( (UnderWaterPos468).xz / _CausticsScale );
				float2 temp_output_95_0 = ( _CausticsSpeed * _TimeParameters.x * 0.01 );
				float FresnelFactor547 = lerpResult258;
				float clampResult437 = clamp( ( WaterDepth2492 / _WaterDeep ) , 0.0 , 1.0 );
				float clampResult268 = clamp( max( FresnelFactor547 , ( FresnelFactor547 + clampResult437 ) ) , 0.0 , 1.0 );
				float WaterDepthRange545 = clampResult268;
				#ifdef _CAUSTICS_ON
				float4 staticSwitch618 = ( ( min( tex2D( _CausticsTex, ( temp_output_91_0 + temp_output_95_0 ) ) , tex2D( _CausticsTex, ( -temp_output_91_0 + temp_output_95_0 ) ) ) * _CausticsIntensity ) * ( 1.0 - WaterDepthRange545 ) );
				#else
				float4 staticSwitch618 = color619;
				#endif
				float4 CausticsColor101 = staticSwitch618;
				float clampResult504 = clamp( max( max( Foam179 , ReflectFresnel487 ) , (CausticsColor101).r ) , 0.0 , 1.0 );
				float lerpResult414 = lerp( WaterOpacity27 , 1.0 , clampResult504);
				float clampResult627 = clamp( ( lerpResult414 * _Alpha ) , 0.0 , 1.0 );
				float FinalAlpha497 = clampResult627;
				

				surfaceDescription.Alpha = FinalAlpha497;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}
			ENDHLSL
		}

		
		Pass
		{
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

			HLSLPROGRAM

			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _VERTEXWAVE_ON
			#pragma shader_feature_local_fragment _FOAM_ON
			#pragma shader_feature_local_fragment _WATERQULIATY_LOW _WATERQULIATY_MID _WATERQULIATY_HIGH
			#pragma shader_feature_local_fragment _CAUSTICS_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _WaveColor;
			float4 _SubWaveDirection;
			float4 _FresnelColor;
			float4 _DeepColor;
			float4 _ShallowColor;
			float4 _FoamColor;
			float2 _Direction;
			float2 _FoamNoiseSpeed;
			float2 _CausticsSpeed;
			float _ReflectIntensity;
			float _CausticsScale;
			float _CausticsIntensity;
			float _DayIntensity;
			float _SparklesIntensity;
			float _ReflectDistort;
			float _FoamOffset;
			float _FoamRange;
			float _XTilling;
			float _YTilling;
			float _SparklesAmount;
			float _WaveSpeed;
			float _ReflectionAngle;
			float _FresnelIntensity;
			float _ShoreDistance;
			float _UnderWaterDistort;
			float _LargeNormalIntensity;
			float _LargeNormalTiling;
			float _LargeNormalSpeed;
			float _SmallNormalIntensity;
			float _SmallNormalTiling;
			float _SmallNormalSpeed;
			float _WaveFadeEnd;
			float _WaveFadeStart;
			float _WaveNormalStr;
			float _WaveHeight;
			float _WaveDistance;
			float _WaterDeep;
			float _Alpha;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _FoamNoise;
			sampler2D _WaterNormalSmall;
			sampler2D _WaterNormalLarge;
			sampler2D _CausticsTex;


			float3 ReconstructWorldPos459( float2 ScreenUV, float rawdepth )
			{
				#if UNITY_REVERSED_Z
				real depth = rawdepth;
				#else
				real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, rawdepth);
				#endif
				float3 worldPos = ComputeWorldSpacePosition(ScreenUV, depth, UNITY_MATRIX_I_VP);
				return worldPos;
			}
			

			float4 _SelectionID;


			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float localGetWaveInfo571 = ( 0.0 );
				float2 position571 = (ase_worldPos).xz;
				float2 time571 = ( _WaveSpeed * _TimeParameters.x * _Direction );
				float4 directionABCD571 = _SubWaveDirection;
				float wavedistance571 = _WaveDistance;
				float height571 = _WaveHeight;
				float normalStr571 = _WaveNormalStr;
				float fadeStart571 = _WaveFadeStart;
				float fadeEnd571 = _WaveFadeEnd;
				float3 positionWSOffset571 = float3( 0,0,0 );
				float3 normalWS571 = float3( 0,0,0 );
				{
				 
				}
				float3 worldToObj583 = mul( GetWorldToObjectMatrix(), float4( ( ase_worldPos + positionWSOffset571 ), 1 ) ).xyz;
				#ifdef _VERTEXWAVE_ON
				float3 staticSwitch607 = worldToObj583;
				#else
				float3 staticSwitch607 = v.vertex.xyz;
				#endif
				float3 WaveVertexPos194 = staticSwitch607;
				
				float3 worldToObjDir584 = normalize( mul( GetWorldToObjectMatrix(), float4( normalWS571, 0 ) ).xyz );
				#ifdef _VERTEXWAVE_ON
				float3 staticSwitch611 = worldToObjDir584;
				#else
				float3 staticSwitch611 = v.ase_normal;
				#endif
				float3 WaveVertexNormal200 = staticSwitch611;
				
				float3 vertexToFrag652 = WaveVertexPos194;
				o.ase_texcoord.xyz = vertexToFrag652;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				o.ase_texcoord5.xyz = ase_worldPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = WaveVertexPos194;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = WaveVertexNormal200;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float3 vertexToFrag652 = IN.ase_texcoord.xyz;
				float4 objectToClip8_g2 = TransformObjectToHClip(vertexToFrag652);
				float3 objectToClip8_g2NDC = objectToClip8_g2.xyz/objectToClip8_g2.w;
				float4 appendResult13_g2 = (float4(objectToClip8_g2NDC , 1.0));
				float4 computeScreenPos10_g2 = ComputeScreenPos( appendResult13_g2 );
				float4 ScreenPos649 = computeScreenPos10_g2;
				float clampDepth465 = SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPos649.xy );
				float depthToLinear469 = LinearEyeDepth(clampDepth465,_ZBufferParams);
				float depthToLinear423 = LinearEyeDepth(ScreenPos649.z,_ZBufferParams);
				float WaterDepth2492 = ( depthToLinear469 - depthToLinear423 );
				float clampResult291 = clamp( ( WaterDepth2492 / _ShoreDistance ) , 0.0 , 1.0 );
				float WaterOpacity27 = clampResult291;
				float temp_output_478_0 = ( WaterDepth2492 / _FoamRange );
				float clampResult149 = clamp( ( _FoamOffset + temp_output_478_0 ) , 0.0 , 1.0 );
				float temp_output_150_0 = ( 1.0 - clampResult149 );
				float2 texCoord371 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float clampResult479 = clamp( temp_output_478_0 , 0.0 , 1.0 );
				float2 appendResult384 = (float2(( _XTilling * texCoord371.x ) , ( clampResult479 * _YTilling )));
				float2 panner382 = ( 1.0 * _Time.y * _FoamNoiseSpeed + appendResult384);
				float depthToLinear446 = LinearEyeDepth((0),_ZBufferParams);
				#ifdef _FOAM_ON
				float staticSwitch624 = step( 0.0 , ( depthToLinear469 - depthToLinear446 ) );
				#else
				float staticSwitch624 = 0.0;
				#endif
				float FoamMask567 = staticSwitch624;
				float clampResult411 = clamp( ( ( temp_output_150_0 - -1.0 ) * step( tex2D( _FoamNoise, panner382 ).r , temp_output_150_0 ) * FoamMask567 ) , 0.0 , 1.0 );
				#ifdef _FOAM_ON
				float staticSwitch614 = clampResult411;
				#else
				float staticSwitch614 = 0.0;
				#endif
				float Foam179 = staticSwitch614;
				float temp_output_40_0 = ( _SmallNormalSpeed * _TimeParameters.x * 0.1 );
				float2 texCoord314 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_315_0 = ( texCoord314 * _SmallNormalTiling );
				float2 panner316 = ( temp_output_40_0 * float2( 0.1,0.1 ) + temp_output_315_0);
				float3 tex2DNode43 = UnpackNormalScale( tex2D( _WaterNormalSmall, panner316 ), 1.0f );
				float2 panner318 = ( temp_output_40_0 * float2( -0.1,-0.1 ) + ( temp_output_315_0 + 0.4 ));
				float3 temp_output_52_0 = BlendNormal( tex2DNode43 , UnpackNormalScale( tex2D( _WaterNormalSmall, panner318 ), 1.0f ) );
				float2 panner321 = ( temp_output_40_0 * float2( -0.1,0.1 ) + ( temp_output_315_0 + float2( 0.85,0.15 ) ));
				float2 panner324 = ( temp_output_40_0 * float2( 0.1,-0.1 ) + ( temp_output_315_0 + float2( 0.65,0.75 ) ));
				#if defined(_WATERQULIATY_LOW)
				float3 staticSwitch630 = tex2DNode43;
				#elif defined(_WATERQULIATY_MID)
				float3 staticSwitch630 = temp_output_52_0;
				#elif defined(_WATERQULIATY_HIGH)
				float3 staticSwitch630 = BlendNormal( temp_output_52_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalSmall, panner321 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalSmall, panner324 ), 1.0f ) ) );
				#else
				float3 staticSwitch630 = BlendNormal( temp_output_52_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalSmall, panner321 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalSmall, panner324 ), 1.0f ) ) );
				#endif
				float3 lerpResult327 = lerp( float3(0,0,1) , staticSwitch630 , _SmallNormalIntensity);
				float3 SmallNormal44 = lerpResult327;
				float temp_output_333_0 = ( _LargeNormalSpeed * _TimeParameters.x * 0.1 );
				float2 texCoord340 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_337_0 = ( texCoord340 * _LargeNormalTiling );
				float2 panner350 = ( temp_output_333_0 * float2( 0.1,0.1 ) + temp_output_337_0);
				float3 tex2DNode345 = UnpackNormalScale( tex2D( _WaterNormalLarge, panner350 ), 1.0f );
				float2 panner339 = ( temp_output_333_0 * float2( -0.1,-0.1 ) + ( temp_output_337_0 + 0.4 ));
				float3 temp_output_351_0 = BlendNormal( tex2DNode345 , UnpackNormalScale( tex2D( _WaterNormalLarge, panner339 ), 1.0f ) );
				float2 panner335 = ( temp_output_333_0 * float2( -0.1,0.1 ) + ( temp_output_337_0 + float2( 0.85,0.15 ) ));
				float2 panner338 = ( temp_output_333_0 * float2( 0.1,-0.1 ) + ( temp_output_337_0 + float2( 0.65,0.75 ) ));
				#if defined(_WATERQULIATY_LOW)
				float3 staticSwitch631 = tex2DNode345;
				#elif defined(_WATERQULIATY_MID)
				float3 staticSwitch631 = temp_output_351_0;
				#elif defined(_WATERQULIATY_HIGH)
				float3 staticSwitch631 = BlendNormal( temp_output_351_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalLarge, panner335 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalLarge, panner338 ), 1.0f ) ) );
				#else
				float3 staticSwitch631 = BlendNormal( temp_output_351_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalLarge, panner335 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalLarge, panner338 ), 1.0f ) ) );
				#endif
				float3 lerpResult357 = lerp( float3(0,0,1) , staticSwitch631 , _LargeNormalIntensity);
				float3 LargeNormal358 = lerpResult357;
				float3 normalizeResult366 = normalize( BlendNormal( SmallNormal44 , LargeNormal358 ) );
				float3 SurfaceNormal361 = normalizeResult366;
				float3 ase_worldTangent = IN.ase_texcoord2.xyz;
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal252 = SurfaceNormal361;
				float3 worldNormal252 = normalize( float3(dot(tanToWorld0,tanNormal252), dot(tanToWorld1,tanNormal252), dot(tanToWorld2,tanNormal252)) );
				float3 ase_worldPos = IN.ase_texcoord5.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult253 = dot( worldNormal252 , ase_worldViewDir );
				float temp_output_255_0 = ( 1.0 - max( dotResult253 , 0.0 ) );
				float lerpResult258 = lerp( 0.04 , 1.0 , ( temp_output_255_0 * temp_output_255_0 * temp_output_255_0 * temp_output_255_0 * temp_output_255_0 ));
				float temp_output_272_0 = pow( lerpResult258 , _ReflectionAngle );
				float clampResult481 = clamp( temp_output_272_0 , 0.0 , 1.0 );
				float ReflectFresnel487 = clampResult481;
				float4 color619 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
				float2 ScreenUV459 = ScreenPos649.xy;
				float rawdepth459 = clampDepth465;
				float3 localReconstructWorldPos459 = ReconstructWorldPos459( ScreenUV459 , rawdepth459 );
				float3 UnderWaterPos468 = localReconstructWorldPos459;
				float2 temp_output_91_0 = ( (UnderWaterPos468).xz / _CausticsScale );
				float2 temp_output_95_0 = ( _CausticsSpeed * _TimeParameters.x * 0.01 );
				float FresnelFactor547 = lerpResult258;
				float clampResult437 = clamp( ( WaterDepth2492 / _WaterDeep ) , 0.0 , 1.0 );
				float clampResult268 = clamp( max( FresnelFactor547 , ( FresnelFactor547 + clampResult437 ) ) , 0.0 , 1.0 );
				float WaterDepthRange545 = clampResult268;
				#ifdef _CAUSTICS_ON
				float4 staticSwitch618 = ( ( min( tex2D( _CausticsTex, ( temp_output_91_0 + temp_output_95_0 ) ) , tex2D( _CausticsTex, ( -temp_output_91_0 + temp_output_95_0 ) ) ) * _CausticsIntensity ) * ( 1.0 - WaterDepthRange545 ) );
				#else
				float4 staticSwitch618 = color619;
				#endif
				float4 CausticsColor101 = staticSwitch618;
				float clampResult504 = clamp( max( max( Foam179 , ReflectFresnel487 ) , (CausticsColor101).r ) , 0.0 , 1.0 );
				float lerpResult414 = lerp( WaterOpacity27 , 1.0 , clampResult504);
				float clampResult627 = clamp( ( lerpResult414 * _Alpha ) , 0.0 , 1.0 );
				float FinalAlpha497 = clampResult627;
				

				surfaceDescription.Alpha = FinalAlpha497;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;

				return outColor;
			}

			ENDHLSL
		}

		
		Pass
		{
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On


			HLSLPROGRAM

			#define ASE_ABSOLUTE_VERTEX_POS 1
			#define _SURFACE_TYPE_TRANSPARENT 1
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 140008
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS
        	#pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma shader_feature_local _VERTEXWAVE_ON
			#pragma shader_feature_local_fragment _FOAM_ON
			#pragma shader_feature_local_fragment _WATERQULIATY_LOW _WATERQULIATY_MID _WATERQULIATY_HIGH
			#pragma shader_feature_local_fragment _CAUSTICS_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _WaveColor;
			float4 _SubWaveDirection;
			float4 _FresnelColor;
			float4 _DeepColor;
			float4 _ShallowColor;
			float4 _FoamColor;
			float2 _Direction;
			float2 _FoamNoiseSpeed;
			float2 _CausticsSpeed;
			float _ReflectIntensity;
			float _CausticsScale;
			float _CausticsIntensity;
			float _DayIntensity;
			float _SparklesIntensity;
			float _ReflectDistort;
			float _FoamOffset;
			float _FoamRange;
			float _XTilling;
			float _YTilling;
			float _SparklesAmount;
			float _WaveSpeed;
			float _ReflectionAngle;
			float _FresnelIntensity;
			float _ShoreDistance;
			float _UnderWaterDistort;
			float _LargeNormalIntensity;
			float _LargeNormalTiling;
			float _LargeNormalSpeed;
			float _SmallNormalIntensity;
			float _SmallNormalTiling;
			float _SmallNormalSpeed;
			float _WaveFadeEnd;
			float _WaveFadeStart;
			float _WaveNormalStr;
			float _WaveHeight;
			float _WaveDistance;
			float _WaterDeep;
			float _Alpha;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _FoamNoise;
			sampler2D _WaterNormalSmall;
			sampler2D _WaterNormalLarge;
			sampler2D _CausticsTex;


			float3 ReconstructWorldPos459( float2 ScreenUV, float rawdepth )
			{
				#if UNITY_REVERSED_Z
				real depth = rawdepth;
				#else
				real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, rawdepth);
				#endif
				float3 worldPos = ComputeWorldSpacePosition(ScreenUV, depth, UNITY_MATRIX_I_VP);
				return worldPos;
			}
			

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};

			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float localGetWaveInfo571 = ( 0.0 );
				float2 position571 = (ase_worldPos).xz;
				float2 time571 = ( _WaveSpeed * _TimeParameters.x * _Direction );
				float4 directionABCD571 = _SubWaveDirection;
				float wavedistance571 = _WaveDistance;
				float height571 = _WaveHeight;
				float normalStr571 = _WaveNormalStr;
				float fadeStart571 = _WaveFadeStart;
				float fadeEnd571 = _WaveFadeEnd;
				float3 positionWSOffset571 = float3( 0,0,0 );
				float3 normalWS571 = float3( 0,0,0 );
				{
				 
				}
				float3 worldToObj583 = mul( GetWorldToObjectMatrix(), float4( ( ase_worldPos + positionWSOffset571 ), 1 ) ).xyz;
				#ifdef _VERTEXWAVE_ON
				float3 staticSwitch607 = worldToObj583;
				#else
				float3 staticSwitch607 = v.vertex.xyz;
				#endif
				float3 WaveVertexPos194 = staticSwitch607;
				
				float3 worldToObjDir584 = normalize( mul( GetWorldToObjectMatrix(), float4( normalWS571, 0 ) ).xyz );
				#ifdef _VERTEXWAVE_ON
				float3 staticSwitch611 = worldToObjDir584;
				#else
				float3 staticSwitch611 = v.ase_normal;
				#endif
				float3 WaveVertexNormal200 = staticSwitch611;
				
				float3 vertexToFrag652 = WaveVertexPos194;
				o.ase_texcoord1.xyz = vertexToFrag652;
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				o.ase_texcoord5.xyz = ase_worldPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = WaveVertexPos194;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = WaveVertexNormal200;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_tangent = v.ase_tangent;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			void frag( VertexOutput IN
				, out half4 outNormalWS : SV_Target0
			#ifdef _WRITE_RENDERING_LAYERS
				, out float4 outRenderingLayers : SV_Target1
			#endif
				 )
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;

				float3 vertexToFrag652 = IN.ase_texcoord1.xyz;
				float4 objectToClip8_g2 = TransformObjectToHClip(vertexToFrag652);
				float3 objectToClip8_g2NDC = objectToClip8_g2.xyz/objectToClip8_g2.w;
				float4 appendResult13_g2 = (float4(objectToClip8_g2NDC , 1.0));
				float4 computeScreenPos10_g2 = ComputeScreenPos( appendResult13_g2 );
				float4 ScreenPos649 = computeScreenPos10_g2;
				float clampDepth465 = SHADERGRAPH_SAMPLE_SCENE_DEPTH( ScreenPos649.xy );
				float depthToLinear469 = LinearEyeDepth(clampDepth465,_ZBufferParams);
				float depthToLinear423 = LinearEyeDepth(ScreenPos649.z,_ZBufferParams);
				float WaterDepth2492 = ( depthToLinear469 - depthToLinear423 );
				float clampResult291 = clamp( ( WaterDepth2492 / _ShoreDistance ) , 0.0 , 1.0 );
				float WaterOpacity27 = clampResult291;
				float temp_output_478_0 = ( WaterDepth2492 / _FoamRange );
				float clampResult149 = clamp( ( _FoamOffset + temp_output_478_0 ) , 0.0 , 1.0 );
				float temp_output_150_0 = ( 1.0 - clampResult149 );
				float2 texCoord371 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float clampResult479 = clamp( temp_output_478_0 , 0.0 , 1.0 );
				float2 appendResult384 = (float2(( _XTilling * texCoord371.x ) , ( clampResult479 * _YTilling )));
				float2 panner382 = ( 1.0 * _Time.y * _FoamNoiseSpeed + appendResult384);
				float depthToLinear446 = LinearEyeDepth((0),_ZBufferParams);
				#ifdef _FOAM_ON
				float staticSwitch624 = step( 0.0 , ( depthToLinear469 - depthToLinear446 ) );
				#else
				float staticSwitch624 = 0.0;
				#endif
				float FoamMask567 = staticSwitch624;
				float clampResult411 = clamp( ( ( temp_output_150_0 - -1.0 ) * step( tex2D( _FoamNoise, panner382 ).r , temp_output_150_0 ) * FoamMask567 ) , 0.0 , 1.0 );
				#ifdef _FOAM_ON
				float staticSwitch614 = clampResult411;
				#else
				float staticSwitch614 = 0.0;
				#endif
				float Foam179 = staticSwitch614;
				float temp_output_40_0 = ( _SmallNormalSpeed * _TimeParameters.x * 0.1 );
				float2 texCoord314 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_315_0 = ( texCoord314 * _SmallNormalTiling );
				float2 panner316 = ( temp_output_40_0 * float2( 0.1,0.1 ) + temp_output_315_0);
				float3 tex2DNode43 = UnpackNormalScale( tex2D( _WaterNormalSmall, panner316 ), 1.0f );
				float2 panner318 = ( temp_output_40_0 * float2( -0.1,-0.1 ) + ( temp_output_315_0 + 0.4 ));
				float3 temp_output_52_0 = BlendNormal( tex2DNode43 , UnpackNormalScale( tex2D( _WaterNormalSmall, panner318 ), 1.0f ) );
				float2 panner321 = ( temp_output_40_0 * float2( -0.1,0.1 ) + ( temp_output_315_0 + float2( 0.85,0.15 ) ));
				float2 panner324 = ( temp_output_40_0 * float2( 0.1,-0.1 ) + ( temp_output_315_0 + float2( 0.65,0.75 ) ));
				#if defined(_WATERQULIATY_LOW)
				float3 staticSwitch630 = tex2DNode43;
				#elif defined(_WATERQULIATY_MID)
				float3 staticSwitch630 = temp_output_52_0;
				#elif defined(_WATERQULIATY_HIGH)
				float3 staticSwitch630 = BlendNormal( temp_output_52_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalSmall, panner321 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalSmall, panner324 ), 1.0f ) ) );
				#else
				float3 staticSwitch630 = BlendNormal( temp_output_52_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalSmall, panner321 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalSmall, panner324 ), 1.0f ) ) );
				#endif
				float3 lerpResult327 = lerp( float3(0,0,1) , staticSwitch630 , _SmallNormalIntensity);
				float3 SmallNormal44 = lerpResult327;
				float temp_output_333_0 = ( _LargeNormalSpeed * _TimeParameters.x * 0.1 );
				float2 texCoord340 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_337_0 = ( texCoord340 * _LargeNormalTiling );
				float2 panner350 = ( temp_output_333_0 * float2( 0.1,0.1 ) + temp_output_337_0);
				float3 tex2DNode345 = UnpackNormalScale( tex2D( _WaterNormalLarge, panner350 ), 1.0f );
				float2 panner339 = ( temp_output_333_0 * float2( -0.1,-0.1 ) + ( temp_output_337_0 + 0.4 ));
				float3 temp_output_351_0 = BlendNormal( tex2DNode345 , UnpackNormalScale( tex2D( _WaterNormalLarge, panner339 ), 1.0f ) );
				float2 panner335 = ( temp_output_333_0 * float2( -0.1,0.1 ) + ( temp_output_337_0 + float2( 0.85,0.15 ) ));
				float2 panner338 = ( temp_output_333_0 * float2( 0.1,-0.1 ) + ( temp_output_337_0 + float2( 0.65,0.75 ) ));
				#if defined(_WATERQULIATY_LOW)
				float3 staticSwitch631 = tex2DNode345;
				#elif defined(_WATERQULIATY_MID)
				float3 staticSwitch631 = temp_output_351_0;
				#elif defined(_WATERQULIATY_HIGH)
				float3 staticSwitch631 = BlendNormal( temp_output_351_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalLarge, panner335 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalLarge, panner338 ), 1.0f ) ) );
				#else
				float3 staticSwitch631 = BlendNormal( temp_output_351_0 , BlendNormal( UnpackNormalScale( tex2D( _WaterNormalLarge, panner335 ), 1.0f ) , UnpackNormalScale( tex2D( _WaterNormalLarge, panner338 ), 1.0f ) ) );
				#endif
				float3 lerpResult357 = lerp( float3(0,0,1) , staticSwitch631 , _LargeNormalIntensity);
				float3 LargeNormal358 = lerpResult357;
				float3 normalizeResult366 = normalize( BlendNormal( SmallNormal44 , LargeNormal358 ) );
				float3 SurfaceNormal361 = normalizeResult366;
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, IN.normalWS.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, IN.normalWS.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, IN.normalWS.z );
				float3 tanNormal252 = SurfaceNormal361;
				float3 worldNormal252 = normalize( float3(dot(tanToWorld0,tanNormal252), dot(tanToWorld1,tanNormal252), dot(tanToWorld2,tanNormal252)) );
				float3 ase_worldPos = IN.ase_texcoord5.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult253 = dot( worldNormal252 , ase_worldViewDir );
				float temp_output_255_0 = ( 1.0 - max( dotResult253 , 0.0 ) );
				float lerpResult258 = lerp( 0.04 , 1.0 , ( temp_output_255_0 * temp_output_255_0 * temp_output_255_0 * temp_output_255_0 * temp_output_255_0 ));
				float temp_output_272_0 = pow( lerpResult258 , _ReflectionAngle );
				float clampResult481 = clamp( temp_output_272_0 , 0.0 , 1.0 );
				float ReflectFresnel487 = clampResult481;
				float4 color619 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
				float2 ScreenUV459 = ScreenPos649.xy;
				float rawdepth459 = clampDepth465;
				float3 localReconstructWorldPos459 = ReconstructWorldPos459( ScreenUV459 , rawdepth459 );
				float3 UnderWaterPos468 = localReconstructWorldPos459;
				float2 temp_output_91_0 = ( (UnderWaterPos468).xz / _CausticsScale );
				float2 temp_output_95_0 = ( _CausticsSpeed * _TimeParameters.x * 0.01 );
				float FresnelFactor547 = lerpResult258;
				float clampResult437 = clamp( ( WaterDepth2492 / _WaterDeep ) , 0.0 , 1.0 );
				float clampResult268 = clamp( max( FresnelFactor547 , ( FresnelFactor547 + clampResult437 ) ) , 0.0 , 1.0 );
				float WaterDepthRange545 = clampResult268;
				#ifdef _CAUSTICS_ON
				float4 staticSwitch618 = ( ( min( tex2D( _CausticsTex, ( temp_output_91_0 + temp_output_95_0 ) ) , tex2D( _CausticsTex, ( -temp_output_91_0 + temp_output_95_0 ) ) ) * _CausticsIntensity ) * ( 1.0 - WaterDepthRange545 ) );
				#else
				float4 staticSwitch618 = color619;
				#endif
				float4 CausticsColor101 = staticSwitch618;
				float clampResult504 = clamp( max( max( Foam179 , ReflectFresnel487 ) , (CausticsColor101).r ) , 0.0 , 1.0 );
				float lerpResult414 = lerp( WaterOpacity27 , 1.0 , clampResult504);
				float clampResult627 = clamp( ( lerpResult414 * _Alpha ) , 0.0 , 1.0 );
				float FinalAlpha497 = clampResult627;
				

				surfaceDescription.Alpha = FinalAlpha497;
				surfaceDescription.AlphaClipThreshold = 0.5;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODFadeCrossFade( IN.clipPos );
				#endif

				#if defined(_GBUFFER_NORMALS_OCT)
					float3 normalWS = normalize(IN.normalWS);
					float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms
					float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
					half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
					outNormalWS = half4(packedNormalWS, 0.0);
				#else
					float3 normalWS = IN.normalWS;
					outNormalWS = half4(NormalizeNormalPerPixel(normalWS), 0.0);
				#endif

				#ifdef _WRITE_RENDERING_LAYERS
					uint renderingLayers = GetMeshRenderingLayer();
					outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
				#endif
			}

			ENDHLSL
		}

	
	}
	
	CustomEditor "ASEMaterialInspector"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback "Hidden/InternalErrorShader"
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;53;-6757.348,1952;Inherit;False;2989.379;1116.15;Small Normals;29;322;326;323;312;321;325;310;311;324;313;44;327;52;328;330;43;45;318;316;40;319;315;42;317;320;41;34;314;630;Small Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;331;-6773.348,3152;Inherit;False;3002.933;1172.903;Big Normals;29;346;354;356;359;349;342;343;338;334;335;358;357;351;352;348;345;344;339;350;336;333;353;355;337;332;347;341;340;631;Big Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;314;-6645.348,2048;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;340;-6645.348,3248;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;341;-6629.348,3376;Inherit;False;Property;_LargeNormalTiling;Large Normal Tiling;17;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-6629.348,2176;Inherit;False;Property;_SmallNormalTiling;Small Normal Tiling;13;0;Create;True;0;0;0;False;0;False;10;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;320;-6341.348,2272;Inherit;False;Constant;_Vector2;Vector 2;37;0;Create;True;0;0;0;False;0;False;0.4,0.35;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;337;-6277.348,3248;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-6565.348,2576;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;326;-6405.348,2864;Inherit;False;Constant;_Vector4;Vector 4;37;0;Create;True;0;0;0;False;0;False;0.65,0.75;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;332;-6597.348,3696;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;315;-6277.348,2048;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;355;-6565.348,3776;Inherit;False;Constant;_Float1;Float 1;7;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;353;-6341.348,3472;Inherit;False;Constant;_Vector8;Vector 8;37;0;Create;True;0;0;0;False;0;False;0.4,0.35;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;41;-6597.348,2496;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;354;-6309.348,3824;Inherit;False;Constant;_Vector9;Vector 9;37;0;Create;True;0;0;0;False;0;False;0.85,0.15;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;323;-6309.348,2624;Inherit;False;Constant;_Vector3;Vector 3;37;0;Create;True;0;0;0;False;0;False;0.85,0.15;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;356;-6405.348,4064;Inherit;False;Constant;_Vector7;Vector 7;37;0;Create;True;0;0;0;False;0;False;0.65,0.75;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;317;-6629.348,2368;Inherit;False;Property;_SmallNormalSpeed;Small Normal Speed;14;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;347;-6629.348,3568;Inherit;False;Property;_LargeNormalSpeed;Large Normal Speed;18;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;334;-5973.348,4048;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;322;-5957.348,2608;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-6341.348,2432;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;349;-5957.348,3808;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;333;-6341.348,3632;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;319;-6053.348,2288;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;336;-6053.348,3488;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;325;-5973.348,2848;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;592;-2025.673,4544.479;Inherit;False;2341.999;889.5058;Comment;26;194;607;593;594;200;583;584;582;571;585;581;586;580;587;575;573;579;574;591;572;578;608;609;611;613;610;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;335;-5781.348,3824;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;338;-5781.348,4048;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,-0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;318;-5845.348,2288;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.1,-0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;321;-5781.348,2624;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;350;-5877.348,3248;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;316;-5861.348,2048;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;324;-5781.348,2848;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,-0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;339;-5845.348,3488;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.1,-0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;43;-5541.348,2016;Inherit;True;Property;_WaterNormalSmall;细波纹法线;12;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;343;-5541.348,3792;Inherit;True;Property;_TextureSample5;Texture Sample 5;16;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Instance;345;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;311;-5541.348,2832;Inherit;True;Property;_TextureSample2;Texture Sample 2;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Instance;43;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;345;-5541.348,3216;Inherit;True;Property;_WaterNormalLarge;大波纹法线;16;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;312;-5541.348,2592;Inherit;True;Property;_TextureSample3;Texture Sample 3;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Instance;43;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;342;-5541.348,4032;Inherit;True;Property;_TextureSample6;Texture Sample 6;16;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Instance;345;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;574;-1944.673,4793.461;Inherit;False;Property;_WaveSpeed;水波速度;40;0;Create;False;0;0;0;False;0;False;2.4;2.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;344;-5557.348,3456;Inherit;True;Property;_TextureSample4;Texture Sample 4;16;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Instance;345;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;591;-1965.652,4998.505;Inherit;True;Property;_Direction;水波运动方向（XY）;39;0;Create;False;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WorldPosInputsNode;572;-1706.602,4594.479;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;578;-1975.673,4883.461;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;45;-5541.348,2256;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Instance;43;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;580;-1537.804,5246.581;Inherit;False;Property;_WaveFadeStart;水波渐隐Start;45;0;Create;False;0;0;0;False;0;False;25;25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;585;-1555.49,5159.58;Inherit;False;Property;_WaveNormalStr;水波法线强度;44;0;Create;False;0;0;0;False;0;False;0.16;0.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;587;-1543.416,4868.456;Inherit;False;Property;_SubWaveDirection;细节波形方向（XYZW）;43;0;Create;False;0;0;0;False;0;False;-1,-1,-1,-1;-1,-1,-1,-1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;52;-5140.049,2335.201;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;573;-1504.154,4677.077;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;581;-1546.984,5323.811;Inherit;False;Property;_WaveFadeEnd;水波渐隐End;46;0;Create;False;0;0;0;False;0;False;280;280;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;586;-1718.647,4995.698;Inherit;False;Property;_WaveDistance;水波大小;41;0;Create;False;0;0;0;False;0;False;0.7;0.7;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;313;-5141.348,2688;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;351;-5141.348,3504;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;346;-5141.348,3888;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;579;-1535.701,5068.034;Inherit;False;Property;_WaveHeight;水波高度;42;0;Create;False;0;0;0;False;0;False;0.15;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;575;-1740.673,4789.461;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendNormalsNode;310;-4861.158,2543.001;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;359;-4869.348,3744;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;582;-750.457,4620.056;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;328;-4594.76,2245.401;Inherit;False;Constant;_Vector5;Vector 5;37;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;348;-4667.138,3468.325;Inherit;False;Constant;_Vector6;Vector 6;37;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;630;-4606.198,2445.288;Inherit;False;Property;_WaterQuliaty;水动画质量;11;0;Create;False;0;0;0;False;2;Header((Water Normal));Space(5);False;0;2;2;True;;KeywordEnum;3;LOW;MID;HIGH;Create;True;True;Fragment;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;352;-4596.724,3940.092;Inherit;False;Property;_LargeNormalIntensity;Large Normal Intensity;19;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;330;-4674.76,2686.401;Inherit;False;Property;_SmallNormalIntensity;Small Normal Intensity;15;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;631;-4564.547,3698.371;Inherit;False;Property;_WaterQuliaty1;水动画质量;11;0;Create;False;0;0;0;False;0;False;0;2;2;True;;KeywordEnum;3;LOW;MID;HIGH;Reference;630;True;True;Fragment;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;583;-503.0161,4611.152;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;327;-4320.56,2435.2;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;357;-4242.972,3681.7;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;608;-508.1567,4799.453;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;607;-229.8416,4681.122;Inherit;False;Property;_VERTEXWAVE;顶点波纹动画;38;0;Create;False;0;0;0;False;2;Header((Wave));Space(5);False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;358;-4066.972,3681.7;Inherit;False;LargeNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-4019.961,2439.701;Inherit;False;SmallNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;628;-6721.689,4353.574;Inherit;False;44;SmallNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;629;-6704.562,4494.274;Inherit;False;358;LargeNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;366;-6008.497,4384.79;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;549;-6712.509,1103.015;Inherit;False;2584.837;577.0111;Fresnel;19;275;252;254;253;256;255;494;258;547;273;272;481;487;485;260;261;259;263;262;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;361;-5809.182,4378.762;Inherit;False;SurfaceNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;1;-2079.454,-554.4202;Inherit;False;2171.041;784.2203;Water Depth;23;622;446;566;570;449;471;447;472;433;425;567;569;455;468;492;459;422;423;469;427;465;624;650;Water Depth;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;275;-6662.509,1168.536;Inherit;False;361;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;650;-1986.823,-434.9796;Inherit;False;649;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;427;-1542.178,-372.2175;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ScreenDepthNode;465;-1574.238,-511.7176;Inherit;False;1;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;256;-6031.771,1264.755;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LinearDepthNode;423;-1242.939,-299.1747;Inherit;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LinearDepthNode;469;-1216.139,-500.9234;Inherit;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;255;-5878.694,1266.421;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;422;-812.3734,-442.0891;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;459;-1393.452,-426.4565;Inherit;False;#if UNITY_REVERSED_Z$real depth = rawdepth@$#else$real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, rawdepth)@$#endif$float3 worldPos = ComputeWorldSpacePosition(ScreenUV, depth, UNITY_MATRIX_I_VP)@$return worldPos@;3;Create;2;True;ScreenUV;FLOAT2;0,0;In;;Inherit;False;True;rawdepth;FLOAT;0;In;;Inherit;False;ReconstructWorldPos;True;False;0;;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;492;-528.9505,-428.643;Inherit;False;WaterDepth2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;494;-5674.433,1225.052;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;180;-2044.752,3389.459;Inherit;False;2460.068;1106.858;Foam Color;30;407;406;179;411;181;176;381;182;372;382;384;383;385;479;386;150;149;404;405;484;371;483;478;148;477;495;568;564;614;615;Foam Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;19;-2054.006,331.9429;Inherit;False;2357.236;1101.692;Water Color;22;545;268;264;437;436;16;434;596;251;595;21;271;486;269;24;11;13;10;265;548;598;597;Water Color;0.1020221,0.5797669,0.8161765,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;104;-253.7981,1592.509;Inherit;False;2422.145;803.8394;Caustics Color;22;101;618;619;112;544;102;546;116;103;100;113;93;115;95;114;91;97;98;96;92;90;89;Caustics Color;0.7379313,0,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;434;-2016.37,1143.031;Inherit;False;492;WaterDepth2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;468;-1101.378,-417.2772;Inherit;False;UnderWaterPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-2000.146,1244.595;Inherit;False;Property;_WaterDeep;水深浅范围;2;0;Create;False;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-1995.427,3739.037;Inherit;False;Property;_FoamRange;泡沫范围;34;0;Create;False;0;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-148.1402,1642.656;Inherit;False;468;UnderWaterPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;436;-1768.37,1193.031;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;478;-1818.771,3710.173;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateFragmentDataNode;455;-1562.703,58.10109;Inherit;False;0;1;clipPos;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;548;-1557.988,1072.124;Inherit;False;547;FresnelFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;371;-1934.347,4204.643;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LinearDepthNode;446;-1250.415,86.7164;Inherit;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;90;89.15666,1642.509;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;483;-1872.732,4113.379;Inherit;False;Property;_XTilling;泡沫TillingX;30;0;Create;False;0;0;0;False;0;False;10;37.52;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;479;-1599.946,3872.685;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;437;-1604.25,1206.301;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;386;-1649.322,4010.193;Inherit;False;Property;_YTilling;泡沫TillingY;31;0;Create;False;0;0;0;False;0;False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;48.15664,1763.509;Inherit;False;Property;_CausticsScale;焦散大小;25;0;Create;False;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;98;9.154695,1919.922;Inherit;False;Property;_CausticsSpeed;焦散速度;26;0;Create;False;0;0;0;False;0;False;-8,0;-8,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;264;-1263.239,1184.175;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;385;-1435.643,3962.207;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;96;18.4784,2047.778;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;484;-1699.885,4169.742;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;566;-822.3452,-242.0335;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;36.92546,2124.296;Inherit;False;Constant;_Float6;Float 6;15;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;405;-1849.141,3534.893;Inherit;False;Property;_FoamOffset;泡沫偏移;33;0;Create;False;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;91;308.1565,1676.509;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;404;-1644.151,3624.933;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;383;-1296.356,4301.239;Inherit;False;Property;_FoamNoiseSpeed;泡沫速度;32;0;Create;False;0;0;0;False;0;False;0,-0.3;0,-0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMaxOpNode;265;-1096.006,1101.839;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;114;423.9215,1933.072;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;255.2105,2020.349;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;569;-646.8701,-260.1266;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;384;-1248.196,4157.228;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;632.1563,1675.509;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;624;-440.1572,-229.6137;Inherit;False;Property;_UNDERWATER2;水底;28;0;Create;False;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;614;True;True;Fragment;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;268;-722.4126,1101.158;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;382;-1040.845,4152.915;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;149;-1527.25,3711.502;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;115;619.263,2003.638;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;372;-856.3123,4123.585;Inherit;True;Property;_FoamNoise;泡沫Noise;29;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;100;793.1563,1647.509;Inherit;True;Property;_CausticsTex;焦散图;24;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;150;-1336.053,3707.048;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;567;-181.5435,-266.3618;Inherit;False;FoamMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;113;775.4913,1974.393;Inherit;True;Property;_TextureSample1;Texture Sample 1;24;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;100;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;495;-996.5601,3602.558;Inherit;False;Constant;_Float2;Float 2;40;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;546;1099.4,2167.614;Inherit;False;545;WaterDepthRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;116;1106.922,1840.069;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;103;1118.791,1981.297;Inherit;False;Property;_CausticsIntensity;焦散亮度;27;0;Create;False;0;0;0;False;0;False;1;0.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;568;-767.0929,3503.669;Inherit;False;567;FoamMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;176;-680.44,3654.798;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;381;-585.9371,3859.194;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;1337.791,1856.296;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-360.6551,3639.804;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;544;1350.796,2128.302;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;-5333.585,1366.491;Inherit;False;Property;_ReflectionAngle;菲涅尔反射角度;5;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;617;-86.07019,3482.873;Inherit;False;Constant;_Float8;Float 8;50;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;272;-5114.413,1316.691;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;619;1475.112,1673.594;Inherit;False;Constant;_Color0;Color 0;51;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;1533.757,1925.655;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;411;-71.17676,3644.594;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;481;-4848.977,1153.015;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;618;1692.413,1890.945;Inherit;False;Property;_Caustics;焦散动画;23;0;Create;False;0;0;0;False;2;Header((Caustics));Space(5);False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;Fragment;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;496;1043.174,2646.558;Inherit;False;1746.843;758.4836;Alpha;19;503;497;627;625;414;626;504;213;563;27;501;291;562;376;499;502;439;438;276;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;614;76.59351,3476.401;Inherit;False;Property;_FOAM;岸边泡沫;28;0;Create;False;0;0;0;False;2;Header((Foam));Space(5);False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;Fragment;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;179;205.9429,3656.28;Inherit;False;Foam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;1898.681,1890.374;Inherit;False;CausticsColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;438;1093.174,2696.558;Inherit;False;492;WaterDepth2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;276;1104.161,2863.372;Inherit;False;Property;_ShoreDistance;水透明范围;8;0;Create;False;0;0;0;False;0;False;1.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;439;1381.174,2742.559;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;502;1117.761,3182.705;Inherit;False;487;ReflectFresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;376;1153.968,3069.839;Inherit;False;179;Foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;499;1141.428,3286.417;Inherit;False;101;CausticsColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;562;1375.721,3202.581;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;501;1345.998,3318.448;Inherit;False;FLOAT;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;291;1619.81,2739.712;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;563;1540.721,3253.581;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;1877.196,2723.507;Inherit;False;WaterOpacity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;504;1776.761,3137.705;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;213;1489.201,2997.237;Inherit;False;27;WaterOpacity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;414;1920.285,3017.159;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;626;1943.163,3219.537;Inherit;False;Property;_Alpha;总体透明度控制;9;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;613;-461.1256,5264.41;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;625;2149.163,3085.537;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;584;-517.9888,5078.649;Inherit;False;World;Object;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;611;-207.1256,5110.41;Inherit;False;Property;_VERTEXWAVE2;VERTEXWAVE;38;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;607;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;627;2275.163,3110.537;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;200;50.78388,5064.93;Inherit;False;WaveVertexNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;550;-6730.511,4759.807;Inherit;False;1483.719;522.8035;Splakes;7;561;559;537;560;540;536;535;Splakes;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;79;-2053.536,1593.248;Inherit;False;1753.72;842.3602;UnderWater Color;15;78;76;75;432;363;70;431;450;77;451;72;119;620;621;651;UnderWater Color;1,0.6827586,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;30;-2047.93,2573.62;Inherit;False;1793.607;564.0559;ReflectColor;10;274;65;217;236;87;364;488;216;218;233;ReflectColor;0,0.006896734,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;497;2446.52,3099.479;Inherit;False;FinalAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-1705.536,1948.248;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenColorNode;70;-1021.841,1830.203;Inherit;False;Global;_GrabScreen0;Grab Screen 0;10;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;560;-6393.968,4968.464;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;-1868.621,699.1687;Inherit;False;Property;_FresnelColor;菲涅尔颜色;3;0;Create;False;0;0;0;False;0;False;0.3686275,0.6431373,0.9137255,0;0.3669009,0.6433284,0.9150943,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-1170.853,1836.58;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;408;2407.244,1006.853;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;78;-505.4326,1881.661;Inherit;False;UnderWaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;503;1364.761,3107.705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;308;1867.276,1178.116;Inherit;False;Property;_DayIntensity;总体亮度控制;10;0;Create;False;0;0;0;False;0;False;0.75;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;432;-1539.522,1968.142;Inherit;False;ScreenDistort;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;425;-1728.627,-101.0579;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;410;2175.447,1210.744;Inherit;False;179;Foam;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;407;205.8506,4094.498;Inherit;False;FoamColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-822.608,1852.571;Inherit;False;SceneColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;216;-1909.132,2631.424;Inherit;False;Constant;_Vector0;Vector 0;32;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;621;-884.6715,2052.62;Inherit;False;Constant;_Color1;Color 1;52;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;2023.814,1003.797;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;218;-1981.133,2872.425;Inherit;False;Property;_ReflectDistort;反射扭曲;21;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;-4809.998,1306.026;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;364;-1951.72,2773.793;Inherit;False;361;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenDepthNode;471;-1583.122,-112.6155;Inherit;False;1;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;609;-191.1568,4887.154;Inherit;False;Property;_VERTEXWAVE1;VERTEXWAVE;38;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;607;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;540;-6533.334,5078.943;Inherit;False;Property;_SparklesAmount;波光数量;37;0;Create;False;0;0;0;False;0;False;0.09;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;488;-875.064,2961.739;Inherit;False;487;ReflectFresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;271;-1298.681,576.3715;Inherit;False;78;UnderWaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;1555.003,973.8758;Inherit;False;65;ReflectColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;431;-1811.616,1855.386;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;564;-323.22,4308.273;Inherit;False;Constant;_Float4;Float 4;40;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;1560.139,872.8199;Inherit;False;24;WaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;451;-1308.921,2009.926;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;233;-628.6934,2665.169;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;597;-1535.361,979.293;Inherit;False;594;WaveY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-489.438,2651.563;Inherit;False;ReflectColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;622;-457.0151,-17.08348;Inherit;False;Property;_UNDERWATER1;水底;6;0;Create;False;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;620;True;True;Fragment;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;409;2149.342,1122.008;Inherit;False;407;FoamColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;269;-1028.309,451.0386;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;595;-1400.317,830.1355;Inherit;False;Property;_WaveColor;波峰颜色;47;1;[HDR];Create;False;0;0;0;False;0;False;0.3686275,0.6431373,0.9137255,0;0.3686275,0.6431373,0.9137255,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;274;-1000.808,2641.209;Inherit;True;Property;_ReflectCube;反射图;20;0;Create;False;0;0;0;False;2;Header((Reflection));Space(5);False;-1;None;None;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;535;-5744.098,5023.642;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldReflectionVector;236;-1358.104,2676.476;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;83;1857.875,998.5416;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;262;-4645.998,1298.026;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-1304.918,391.7983;Inherit;False;Property;_ShallowColor;浅水颜色;0;0;Create;False;0;0;0;False;2;Header((Color Settings));Space(5);False;0.4862745,1,0.8588235,0;0.485849,1,0.8603815,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;13;-671.634,640.3411;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1997.536,2076.249;Inherit;False;Constant;_Float5;Float 5;11;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-191.7044,633.7484;Inherit;False;WaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;251;-1360.691,686.2524;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;620;-613.697,1990.61;Inherit;False;Property;_UNDERWATER;水底图;6;0;Create;False;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;Fragment;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;-17.11719,4101.44;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;363;-2003.053,1852.959;Inherit;False;361;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;263;-4499.997,1296.026;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;449;-191.3635,-25.12018;Inherit;False;RefractionMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;447;-918.937,-34.01051;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;570;-649.438,-17.57834;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;260;-5062.997,1475.026;Inherit;False;Property;_FresnelIntensity;菲涅尔强度;4;0;Create;False;0;0;0;False;0;False;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;182;-390.5433,4116.394;Inherit;False;Property;_FoamColor;泡沫颜色;35;0;Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;610;-325.1256,4860.41;Inherit;False;Constant;_Float7;Float 7;49;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;594;33.6135,4867.046;Inherit;False;WaveY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;261;-5000.998,1564.026;Inherit;False;Constant;_Float9;Float 9;33;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;542;1549.457,1085.392;Inherit;False;101;CausticsColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;10;-1874.535,500.1665;Inherit;False;Property;_DeepColor;深水颜色;1;0;Create;False;0;0;0;False;0;False;0,0.4666667,0.7450981,0;0,0.4673787,0.7450981,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;651;-1491.639,1706.661;Inherit;False;649;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;598;-1250.323,978.7654;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LinearDepthNode;472;-1251.853,-118.4952;Inherit;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;596;-1056.217,759.8046;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-901.649,2848.399;Inherit;False;Property;_ReflectIntensity;反射强度;22;0;Create;False;0;0;0;False;0;False;1;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;561;-6121.812,4976.391;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;537;-5604.576,5023.973;Inherit;False;Splakes;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;559;-6622.46,4956.77;Inherit;False;361;SurfaceNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;536;-5931.09,5130.643;Inherit;False;Property;_SparklesIntensity;波光亮度;36;0;Create;False;0;0;0;False;2;Header(Sparkles);Space(5);False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;433;-1973.931,49.1733;Inherit;False;432;ScreenDistort;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;615;71.92981,3969.873;Inherit;False;Property;_FOAM1;岸边泡沫;28;0;Create;False;0;0;0;False;2;Header((Foam));Space(5);False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;614;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-2002.536,1974.248;Inherit;False;Property;_UnderWaterDistort;水底折射;7;0;Create;False;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;538;1574.626,1183.497;Inherit;False;537;Splakes;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;217;-1577.133,2679.424;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;450;-1540.526,2133.999;Inherit;False;449;RefractionMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;2515.237,1469.376;Inherit;False;200;WaveVertexNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;498;2555.855,1254.989;Inherit;False;497;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;593;-467.2854,4927.321;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;636;2837.034,1030.68;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;632;2837.034,1030.68;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;635;2837.034,1030.68;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;637;2837.034,1030.68;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;641;2837.034,1030.68;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;639;2837.034,1030.68;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;640;2837.034,1030.68;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;634;2837.034,1030.68;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;638;2837.034,1030.68;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;633;2858.086,1003.241;Float;False;True;-1;2;ASEMaterialInspector;0;13;CartoonWater;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;5;False;;10;False;;1;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;23;Surface;1;638155104196505887;  Blend;0;0;Two Sided;1;0;Forward Only;0;0;Cast Shadows;0;638155104219321407;  Use Shadow Threshold;0;0;Receive Shadows;0;638155104246092684;GPU Instancing;0;638310908996915772;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;0;638155104175866008;0;10;False;True;False;True;False;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;2518.026,1369.448;Inherit;False;194;WaveVertexPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;652;2828.154,1556.367;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;477;-1989.771,3623.173;Inherit;False;492;WaterDepth2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;9.748559,4600.398;Inherit;False;WaveVertexPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;360;-6330.204,4373.357;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;253;-6152.771,1232.755;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;254;-6363.772,1316.755;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;252;-6379.772,1168.755;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;258;-5489.703,1178.17;Inherit;False;3;0;FLOAT;0.04;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;547;-5189.772,1169.425;Inherit;False;FresnelFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;487;-4681.069,1153.728;Inherit;False;ReflectFresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;571;-1187.079,4767.306;Inherit;False; ;7;Create;10;True;position;FLOAT2;0,0;In;;Inherit;False;True;time;FLOAT2;0,0;In;;Inherit;False;True;directionABCD;FLOAT4;0,0,0,0;In;;Inherit;False;True;wavedistance;FLOAT;0;In;;Inherit;False;True;height;FLOAT;0;In;;Inherit;False;True;normalStr;FLOAT;0;In;;Inherit;False;True;fadeStart;FLOAT;0;In;;Inherit;False;True;fadeEnd;FLOAT;0;In;;Inherit;False;True;positionWSOffset;FLOAT3;0,0,0;Out;;Inherit;False;True;normalWS;FLOAT3;0,0,0;Out;;Inherit;False;GetWaveInfo;False;False;0;;False;11;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT3;0,0,0;False;10;FLOAT3;0,0,0;False;3;FLOAT;0;FLOAT3;10;FLOAT3;11
Node;AmplifyShaderEditor.RegisterLocalVarNode;485;-4345.672,1291.572;Inherit;False;ColorFresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;486;-1838.777,885.3345;Inherit;False;485;ColorFresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;545;-298.7202,1122.281;Inherit;False;WaterDepthRange;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;649;3330.911,1549.691;Inherit;False;ScreenPos;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;647;3032.911,1556.691;Inherit;False;Custom Screen Position;-1;;2;35530643343074e4bb5fb02a7011bd50;2,9,1,12,0;2;6;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT4;0
WireConnection;337;0;340;0
WireConnection;337;1;341;0
WireConnection;315;0;314;0
WireConnection;315;1;34;0
WireConnection;334;0;337;0
WireConnection;334;1;356;0
WireConnection;322;0;315;0
WireConnection;322;1;323;0
WireConnection;40;0;317;0
WireConnection;40;1;41;0
WireConnection;40;2;42;0
WireConnection;349;0;337;0
WireConnection;349;1;354;0
WireConnection;333;0;347;0
WireConnection;333;1;332;0
WireConnection;333;2;355;0
WireConnection;319;0;315;0
WireConnection;319;1;320;1
WireConnection;336;0;337;0
WireConnection;336;1;353;1
WireConnection;325;0;315;0
WireConnection;325;1;326;0
WireConnection;335;0;349;0
WireConnection;335;1;333;0
WireConnection;338;0;334;0
WireConnection;338;1;333;0
WireConnection;318;0;319;0
WireConnection;318;1;40;0
WireConnection;321;0;322;0
WireConnection;321;1;40;0
WireConnection;350;0;337;0
WireConnection;350;1;333;0
WireConnection;316;0;315;0
WireConnection;316;1;40;0
WireConnection;324;0;325;0
WireConnection;324;1;40;0
WireConnection;339;0;336;0
WireConnection;339;1;333;0
WireConnection;43;1;316;0
WireConnection;343;1;335;0
WireConnection;311;1;324;0
WireConnection;345;1;350;0
WireConnection;312;1;321;0
WireConnection;342;1;338;0
WireConnection;344;1;339;0
WireConnection;45;1;318;0
WireConnection;52;0;43;0
WireConnection;52;1;45;0
WireConnection;573;0;572;0
WireConnection;313;0;312;0
WireConnection;313;1;311;0
WireConnection;351;0;345;0
WireConnection;351;1;344;0
WireConnection;346;0;343;0
WireConnection;346;1;342;0
WireConnection;575;0;574;0
WireConnection;575;1;578;0
WireConnection;575;2;591;0
WireConnection;310;0;52;0
WireConnection;310;1;313;0
WireConnection;359;0;351;0
WireConnection;359;1;346;0
WireConnection;582;0;572;0
WireConnection;582;1;571;10
WireConnection;630;1;43;0
WireConnection;630;0;52;0
WireConnection;630;2;310;0
WireConnection;631;1;345;0
WireConnection;631;0;351;0
WireConnection;631;2;359;0
WireConnection;583;0;582;0
WireConnection;327;0;328;0
WireConnection;327;1;630;0
WireConnection;327;2;330;0
WireConnection;357;0;348;0
WireConnection;357;1;631;0
WireConnection;357;2;352;0
WireConnection;607;1;608;0
WireConnection;607;0;583;0
WireConnection;358;0;357;0
WireConnection;44;0;327;0
WireConnection;366;0;360;0
WireConnection;361;0;366;0
WireConnection;427;0;650;0
WireConnection;465;0;650;0
WireConnection;256;0;253;0
WireConnection;423;0;427;2
WireConnection;469;0;465;0
WireConnection;255;0;256;0
WireConnection;422;0;469;0
WireConnection;422;1;423;0
WireConnection;459;0;650;0
WireConnection;459;1;465;0
WireConnection;492;0;422;0
WireConnection;494;0;255;0
WireConnection;494;1;255;0
WireConnection;494;2;255;0
WireConnection;494;3;255;0
WireConnection;494;4;255;0
WireConnection;468;0;459;0
WireConnection;436;0;434;0
WireConnection;436;1;16;0
WireConnection;478;0;477;0
WireConnection;478;1;148;0
WireConnection;446;0;455;3
WireConnection;90;0;89;0
WireConnection;479;0;478;0
WireConnection;437;0;436;0
WireConnection;264;0;548;0
WireConnection;264;1;437;0
WireConnection;385;0;479;0
WireConnection;385;1;386;0
WireConnection;484;0;483;0
WireConnection;484;1;371;1
WireConnection;566;0;469;0
WireConnection;566;1;446;0
WireConnection;91;0;90;0
WireConnection;91;1;92;0
WireConnection;404;0;405;0
WireConnection;404;1;478;0
WireConnection;265;0;548;0
WireConnection;265;1;264;0
WireConnection;114;0;91;0
WireConnection;95;0;98;0
WireConnection;95;1;96;0
WireConnection;95;2;97;0
WireConnection;569;1;566;0
WireConnection;384;0;484;0
WireConnection;384;1;385;0
WireConnection;93;0;91;0
WireConnection;93;1;95;0
WireConnection;624;0;569;0
WireConnection;268;0;265;0
WireConnection;382;0;384;0
WireConnection;382;2;383;0
WireConnection;149;0;404;0
WireConnection;115;0;114;0
WireConnection;115;1;95;0
WireConnection;372;1;382;0
WireConnection;100;1;93;0
WireConnection;150;0;149;0
WireConnection;567;0;624;0
WireConnection;113;1;115;0
WireConnection;116;0;100;0
WireConnection;116;1;113;0
WireConnection;176;0;150;0
WireConnection;176;1;495;0
WireConnection;381;0;372;1
WireConnection;381;1;150;0
WireConnection;102;0;116;0
WireConnection;102;1;103;0
WireConnection;181;0;176;0
WireConnection;181;1;381;0
WireConnection;181;2;568;0
WireConnection;544;0;546;0
WireConnection;272;0;258;0
WireConnection;272;1;273;0
WireConnection;112;0;102;0
WireConnection;112;1;544;0
WireConnection;411;0;181;0
WireConnection;481;0;272;0
WireConnection;618;1;619;0
WireConnection;618;0;112;0
WireConnection;614;1;617;0
WireConnection;614;0;411;0
WireConnection;179;0;614;0
WireConnection;101;0;618;0
WireConnection;439;0;438;0
WireConnection;439;1;276;0
WireConnection;562;0;376;0
WireConnection;562;1;502;0
WireConnection;501;0;499;0
WireConnection;291;0;439;0
WireConnection;563;0;562;0
WireConnection;563;1;501;0
WireConnection;27;0;291;0
WireConnection;504;0;563;0
WireConnection;414;0;213;0
WireConnection;414;2;504;0
WireConnection;625;0;414;0
WireConnection;625;1;626;0
WireConnection;584;0;571;11
WireConnection;611;1;613;0
WireConnection;611;0;584;0
WireConnection;627;0;625;0
WireConnection;200;0;611;0
WireConnection;497;0;627;0
WireConnection;75;0;431;0
WireConnection;75;1;76;0
WireConnection;75;2;77;0
WireConnection;70;0;72;0
WireConnection;560;0;559;0
WireConnection;72;0;651;0
WireConnection;72;1;451;0
WireConnection;408;0;307;0
WireConnection;408;1;409;0
WireConnection;408;2;410;0
WireConnection;78;0;620;0
WireConnection;503;0;376;0
WireConnection;503;1;502;0
WireConnection;432;0;75;0
WireConnection;425;0;650;0
WireConnection;425;1;433;0
WireConnection;407;0;615;0
WireConnection;119;0;70;0
WireConnection;307;0;83;0
WireConnection;307;1;308;0
WireConnection;259;0;272;0
WireConnection;259;1;260;0
WireConnection;259;2;261;0
WireConnection;471;0;425;0
WireConnection;609;1;610;0
WireConnection;609;0;593;0
WireConnection;431;0;363;0
WireConnection;451;1;432;0
WireConnection;451;2;450;0
WireConnection;233;0;274;0
WireConnection;233;1;87;0
WireConnection;233;2;488;0
WireConnection;65;0;233;0
WireConnection;622;0;570;0
WireConnection;269;0;11;0
WireConnection;269;1;271;0
WireConnection;274;1;236;0
WireConnection;535;0;561;0
WireConnection;535;1;536;0
WireConnection;236;0;217;0
WireConnection;83;0;25;0
WireConnection;83;1;66;0
WireConnection;83;2;542;0
WireConnection;83;3;538;0
WireConnection;262;0;259;0
WireConnection;262;1;259;0
WireConnection;13;0;269;0
WireConnection;13;1;596;0
WireConnection;13;2;268;0
WireConnection;24;0;13;0
WireConnection;251;0;10;0
WireConnection;251;1;21;0
WireConnection;251;2;486;0
WireConnection;620;1;621;0
WireConnection;620;0;119;0
WireConnection;406;0;411;0
WireConnection;406;1;182;0
WireConnection;406;2;564;0
WireConnection;263;0;262;0
WireConnection;449;0;622;0
WireConnection;447;0;472;0
WireConnection;447;1;446;0
WireConnection;570;1;447;0
WireConnection;594;0;609;0
WireConnection;598;0;597;0
WireConnection;472;0;471;0
WireConnection;596;0;251;0
WireConnection;596;1;595;0
WireConnection;596;2;598;0
WireConnection;561;0;540;0
WireConnection;561;1;560;0
WireConnection;537;0;535;0
WireConnection;615;1;182;0
WireConnection;615;0;406;0
WireConnection;217;0;216;0
WireConnection;217;1;364;0
WireConnection;217;2;218;0
WireConnection;593;0;571;10
WireConnection;633;2;408;0
WireConnection;633;3;498;0
WireConnection;633;5;195;0
WireConnection;633;6;201;0
WireConnection;652;0;195;0
WireConnection;194;0;607;0
WireConnection;360;0;628;0
WireConnection;360;1;629;0
WireConnection;253;0;252;0
WireConnection;253;1;254;0
WireConnection;252;0;275;0
WireConnection;258;2;494;0
WireConnection;547;0;258;0
WireConnection;487;0;481;0
WireConnection;571;1;573;0
WireConnection;571;2;575;0
WireConnection;571;3;587;0
WireConnection;571;4;586;0
WireConnection;571;5;579;0
WireConnection;571;6;585;0
WireConnection;571;7;580;0
WireConnection;571;8;581;0
WireConnection;485;0;263;0
WireConnection;545;0;268;0
WireConnection;649;0;647;0
WireConnection;647;6;652;0
ASEEND*/
//CHKSM=7E97D970023F835A7FE32A058F9F009F9D9CCCFF