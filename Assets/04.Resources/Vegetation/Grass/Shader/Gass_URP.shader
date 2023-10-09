// Made with Amplify Shader Editor v1.9.2.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Gass_URP"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[NoScaleOffset]_Alpha("Alpha", 2D) = "white" {}
		_TopColor("Top Color", Color) = (0.5960785,0.7843138,0.09411766,1)
		_BottomColor("Bottom Color", Color) = (0.2431373,0.3411765,0.04705883,1)
		_ColorGradient("Color Gradient", Range( 1 , 10)) = 1
		_ColorGradientScale("Color Gradient Scale", Float) = 1
		_Alphaclip("Alpha clip", Range( 0 , 1)) = 0.35
		[NoScaleOffset]_WindLine("WindLine", 2D) = "white" {}
		_WindLineColor("WindLine Color", Color) = (0.6832584,0.8584906,0.2159724,1)
		_WindLineTilling("WindLine Tilling", Float) = 1
		_WindLineDirection("WindLine Direction", Range( 0 , 2)) = 0
		_WindLineSpeed("WindLine Speed", Vector) = (0,0.3,0,0)
		_WindLineIntensity("WindLine Intensity", Range( 0 , 3)) = 0.6
		_WindDirection("WindDirection", Range( 0 , 360)) = 45
		[Header(Intensity(x)Speed(y)MinScale(z)MaxScale(w))][Space(10)]_WindParams("Wind Params", Vector) = (0.2,0.3,4,10)
		[NoScaleOffset]_ColorRandom("Color Random", 2D) = "white" {}
		_ColorRandomIntensity("Color Random Intensity", Range( 0 , 1)) = 0
		_ColorRandomScale("Color Random Scale", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}


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

		[HideInInspector][ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "UniversalMaterialType"="Unlit" }

		Cull Off
		AlphaToMask Off

		

		HLSLINCLUDE
		#pragma target 4.5
		#pragma prefer_hlslcc gles
		#pragma only_renderers d3d11 // ensure rendering platforms toggle list is visible

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

			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0,0
			ColorMask RGBA

			

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#pragma instancing_options renderinglayer
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140008
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile _ DYNAMICLIGHTMAP_ON
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
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

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_SHADOWCOORDS
			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ _FORWARD_PLUS
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
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
				float4 lightmapUVOrVertexSH : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _WindParams;
			float4 _BottomColor;
			float4 _TopColor;
			float4 _WindLineColor;
			float2 _WindLineSpeed;
			float _WindDirection;
			float _WindLineTilling;
			float _WindLineDirection;
			float _WindLineIntensity;
			float _ColorGradient;
			float _ColorGradientScale;
			float _ColorRandomScale;
			float _ColorRandomIntensity;
			float _Alphaclip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			TEXTURE2D(_WindLine);
			SAMPLER(sampler_WindLine);
			TEXTURE2D(_ColorRandom);
			SAMPLER(sampler_ColorRandom);
			TEXTURE2D(_Alpha);
			SAMPLER(sampler_Alpha);


			float3 RotateXY165_g5( float3 R, float degrees )
			{
				float3 reflUVW = R;
				half theta = degrees * PI / 180.0f;
				half costha = cos(theta);
				half sintha = sin(theta);
				reflUVW = half3(reflUVW.x * costha - reflUVW.z * sintha, reflUVW.y, reflUVW.x * sintha + reflUVW.z * costha);
				return reflUVW;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			
			float3 ASEIndirectDiffuse( float2 uvStaticLightmap, float3 normalWS )
			{
			#ifdef LIGHTMAP_ON
				return SampleLightmap( uvStaticLightmap, normalWS );
			#else
				return SampleSH(normalWS);
			#endif
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 _Vector0 = float3(0,0,1);
				float3 RotateAxis34_g5 = cross( _Vector0 , float3(0,1,0) );
				float3 wind_direction31_g5 = _Vector0;
				float3 wind_speed40_g5 = ( ( _TimeParameters.x * _WindParams.y ) * float3(0.5,-0.5,-0.5) );
				float2 texCoord64 = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord65 = v.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult66 = (float3(-texCoord64.x , texCoord65.x , -texCoord64.y));
				float3 MehsPivotOS69 = appendResult66;
				float3 objToWorld116 = mul( GetObjectToWorldMatrix(), float4( MehsPivotOS69, 1 ) ).xyz;
				float3 vertexToFrag71 = objToWorld116;
				float3 VitualPositionWS72 = vertexToFrag71;
				float3 WorldPosition161_g5 = VitualPositionWS72;
				float3 R165_g5 = WorldPosition161_g5;
				float degrees165_g5 = _WindDirection;
				float3 localRotateXY165_g5 = RotateXY165_g5( R165_g5 , degrees165_g5 );
				float3 temp_cast_0 = (1.0).xxx;
				float3 temp_output_22_0_g5 = abs( ( ( frac( ( ( ( wind_direction31_g5 * wind_speed40_g5 ) + ( localRotateXY165_g5 / _WindParams.w ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
				float3 temp_cast_1 = (3.0).xxx;
				float dotResult30_g5 = dot( ( ( temp_output_22_0_g5 * temp_output_22_0_g5 ) * ( temp_cast_1 - ( temp_output_22_0_g5 * 2.0 ) ) ) , wind_direction31_g5 );
				float BigTriangleWave42_g5 = dotResult30_g5;
				float3 temp_cast_2 = (1.0).xxx;
				float3 temp_output_59_0_g5 = abs( ( ( frac( ( ( wind_speed40_g5 + ( localRotateXY165_g5 / _WindParams.z ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
				float3 temp_cast_3 = (3.0).xxx;
				float SmallTriangleWave52_g5 = distance( ( ( temp_output_59_0_g5 * temp_output_59_0_g5 ) * ( temp_cast_3 - ( temp_output_59_0_g5 * 2.0 ) ) ) , float3(0,0,0) );
				float3 rotatedValue72_g5 = RotateAroundAxis( ( float3( 0,0,0 ) - float3(0,0.1,0) ), WorldPosition161_g5, normalize( RotateAxis34_g5 ), ( ( BigTriangleWave42_g5 + SmallTriangleWave52_g5 ) * ( 2.0 * PI ) ) );
				float2 texCoord21 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float VerticalFade22 = texCoord21.y;
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float2 WorldUV122 = (ase_worldPos).xz;
				float cos49 = cos( ( _WindLineDirection * 3.141593 ) );
				float sin49 = sin( ( _WindLineDirection * 3.141593 ) );
				float2 rotator49 = mul( ( WorldUV122 / _WindLineTilling ) - float2( 0,0 ) , float2x2( cos49 , -sin49 , sin49 , cos49 )) + float2( 0,0 );
				float mulTime56 = _TimeParameters.x * 0.1;
				float WindMask118 = SAMPLE_TEXTURE2D_LOD( _WindLine, sampler_WindLine, ( rotator49 + frac( ( _WindLineSpeed * mulTime56 ) ) ), 0.0 ).r;
				float3 worldToObj90 = mul( GetWorldToObjectMatrix(), float4( ( ( ( ( rotatedValue72_g5 * float3(1,0,1) ) - WorldPosition161_g5 ) * ( VerticalFade22 * VerticalFade22 ) * ( saturate( pow( abs( WindMask118 ) , 2.0 ) ) * _WindLineIntensity * _WindParams.x ) * 0.1 ) + ase_worldPos ), 1 ) ).xyz;
				float3 FinalVertexOffset93 = worldToObj90;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( ase_worldNormal, o.lightmapUVOrVertexSH.xyz );
				o.ase_texcoord5.xyz = ase_worldNormal;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord5.w = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = FinalVertexOffset93;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;

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
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord = v.ase_texcoord;
				o.texcoord1 = v.texcoord1;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
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

				float2 texCoord21 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float VerticalFade22 = texCoord21.y;
				float4 lerpResult34 = lerp( _BottomColor , _TopColor , saturate( ( saturate( pow( abs( VerticalFade22 ) , _ColorGradient ) ) * max( _ColorGradientScale , 1.0 ) ) ));
				float2 WorldUV122 = (WorldPosition).xz;
				float cos49 = cos( ( _WindLineDirection * 3.141593 ) );
				float sin49 = sin( ( _WindLineDirection * 3.141593 ) );
				float2 rotator49 = mul( ( WorldUV122 / _WindLineTilling ) - float2( 0,0 ) , float2x2( cos49 , -sin49 , sin49 , cos49 )) + float2( 0,0 );
				float mulTime56 = _TimeParameters.x * 0.1;
				float WindMask118 = SAMPLE_TEXTURE2D( _WindLine, sampler_WindLine, ( rotator49 + frac( ( _WindLineSpeed * mulTime56 ) ) ) ).r;
				float3 WindLineColor62 = (( WindMask118 * _WindLineColor * VerticalFade22 )).rgb;
				float3 BaseColor36 = ( (lerpResult34).rgb + WindLineColor62 );
				float3 RandomColor132 = (SAMPLE_TEXTURE2D( _ColorRandom, sampler_ColorRandom, ( WorldUV122 / ( _ColorRandomScale * 10.0 ) ) )).rgb;
				float3 lerpResult136 = lerp( BaseColor36 , ( BaseColor36 * RandomColor132 * 2.0 ) , _ColorRandomIntensity);
				float3 GrassColor138 = lerpResult136;
				float ase_lightAtten = 0;
				Light ase_mainLight = GetMainLight( ShadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 bakedGI102 = ASEIndirectDiffuse( IN.lightmapUVOrVertexSH.xy, ase_worldNormal);
				MixRealtimeAndBakedGI(ase_mainLight, ase_worldNormal, bakedGI102, half4(0,0,0,0));
				float ase_lightIntensity = max( max( _MainLightColor.r, _MainLightColor.g ), _MainLightColor.b );
				float4 ase_lightColor = float4( _MainLightColor.rgb / ase_lightIntensity, ase_lightIntensity );
				float3 FinalColor104 = ( ( ( GrassColor138 * ase_lightAtten ) + ( ( 1.0 - ase_lightAtten ) * bakedGI102 * GrassColor138 ) ) * ase_lightColor.rgb );
				
				float2 uv_Alpha38 = IN.ase_texcoord3.xy;
				float Grass_alpha39 = SAMPLE_TEXTURE2D( _Alpha, sampler_Alpha, uv_Alpha38 ).a;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = FinalColor104;
				float Alpha = Grass_alpha39;
				float AlphaClipThreshold = _Alphaclip;
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140008
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

			#define SHADERPASS SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _WindParams;
			float4 _BottomColor;
			float4 _TopColor;
			float4 _WindLineColor;
			float2 _WindLineSpeed;
			float _WindDirection;
			float _WindLineTilling;
			float _WindLineDirection;
			float _WindLineIntensity;
			float _ColorGradient;
			float _ColorGradientScale;
			float _ColorRandomScale;
			float _ColorRandomIntensity;
			float _Alphaclip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			TEXTURE2D(_WindLine);
			SAMPLER(sampler_WindLine);
			TEXTURE2D(_Alpha);
			SAMPLER(sampler_Alpha);


			float3 RotateXY165_g5( float3 R, float degrees )
			{
				float3 reflUVW = R;
				half theta = degrees * PI / 180.0f;
				half costha = cos(theta);
				half sintha = sin(theta);
				reflUVW = half3(reflUVW.x * costha - reflUVW.z * sintha, reflUVW.y, reflUVW.x * sintha + reflUVW.z * costha);
				return reflUVW;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			float3 _LightDirection;
			float3 _LightPosition;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 _Vector0 = float3(0,0,1);
				float3 RotateAxis34_g5 = cross( _Vector0 , float3(0,1,0) );
				float3 wind_direction31_g5 = _Vector0;
				float3 wind_speed40_g5 = ( ( _TimeParameters.x * _WindParams.y ) * float3(0.5,-0.5,-0.5) );
				float2 texCoord64 = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord65 = v.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult66 = (float3(-texCoord64.x , texCoord65.x , -texCoord64.y));
				float3 MehsPivotOS69 = appendResult66;
				float3 objToWorld116 = mul( GetObjectToWorldMatrix(), float4( MehsPivotOS69, 1 ) ).xyz;
				float3 vertexToFrag71 = objToWorld116;
				float3 VitualPositionWS72 = vertexToFrag71;
				float3 WorldPosition161_g5 = VitualPositionWS72;
				float3 R165_g5 = WorldPosition161_g5;
				float degrees165_g5 = _WindDirection;
				float3 localRotateXY165_g5 = RotateXY165_g5( R165_g5 , degrees165_g5 );
				float3 temp_cast_0 = (1.0).xxx;
				float3 temp_output_22_0_g5 = abs( ( ( frac( ( ( ( wind_direction31_g5 * wind_speed40_g5 ) + ( localRotateXY165_g5 / _WindParams.w ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
				float3 temp_cast_1 = (3.0).xxx;
				float dotResult30_g5 = dot( ( ( temp_output_22_0_g5 * temp_output_22_0_g5 ) * ( temp_cast_1 - ( temp_output_22_0_g5 * 2.0 ) ) ) , wind_direction31_g5 );
				float BigTriangleWave42_g5 = dotResult30_g5;
				float3 temp_cast_2 = (1.0).xxx;
				float3 temp_output_59_0_g5 = abs( ( ( frac( ( ( wind_speed40_g5 + ( localRotateXY165_g5 / _WindParams.z ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
				float3 temp_cast_3 = (3.0).xxx;
				float SmallTriangleWave52_g5 = distance( ( ( temp_output_59_0_g5 * temp_output_59_0_g5 ) * ( temp_cast_3 - ( temp_output_59_0_g5 * 2.0 ) ) ) , float3(0,0,0) );
				float3 rotatedValue72_g5 = RotateAroundAxis( ( float3( 0,0,0 ) - float3(0,0.1,0) ), WorldPosition161_g5, normalize( RotateAxis34_g5 ), ( ( BigTriangleWave42_g5 + SmallTriangleWave52_g5 ) * ( 2.0 * PI ) ) );
				float2 texCoord21 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float VerticalFade22 = texCoord21.y;
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float2 WorldUV122 = (ase_worldPos).xz;
				float cos49 = cos( ( _WindLineDirection * 3.141593 ) );
				float sin49 = sin( ( _WindLineDirection * 3.141593 ) );
				float2 rotator49 = mul( ( WorldUV122 / _WindLineTilling ) - float2( 0,0 ) , float2x2( cos49 , -sin49 , sin49 , cos49 )) + float2( 0,0 );
				float mulTime56 = _TimeParameters.x * 0.1;
				float WindMask118 = SAMPLE_TEXTURE2D_LOD( _WindLine, sampler_WindLine, ( rotator49 + frac( ( _WindLineSpeed * mulTime56 ) ) ), 0.0 ).r;
				float3 worldToObj90 = mul( GetWorldToObjectMatrix(), float4( ( ( ( ( rotatedValue72_g5 * float3(1,0,1) ) - WorldPosition161_g5 ) * ( VerticalFade22 * VerticalFade22 ) * ( saturate( pow( abs( WindMask118 ) , 2.0 ) ) * _WindLineIntensity * _WindParams.x ) * 0.1 ) + ase_worldPos ), 1 ) ).xyz;
				float3 FinalVertexOffset93 = worldToObj90;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = FinalVertexOffset93;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
					o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				#if _CASTING_PUNCTUAL_LIGHT_SHADOW
					float3 lightDirectionWS = normalize(_LightPosition - positionWS);
				#else
					float3 lightDirectionWS = _LightDirection;
				#endif

				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = clipPos;

				return o;
			}

			#if defined(ASE_TESSELLATION)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;

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
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				float2 uv_Alpha38 = IN.ase_texcoord2.xy;
				float Grass_alpha39 = SAMPLE_TEXTURE2D( _Alpha, sampler_Alpha, uv_Alpha38 ).a;
				

				float Alpha = Grass_alpha39;
				float AlphaClipThreshold = _Alphaclip;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
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
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM

			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 140008
			#define ASE_USING_SAMPLING_MACROS 1


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _WindParams;
			float4 _BottomColor;
			float4 _TopColor;
			float4 _WindLineColor;
			float2 _WindLineSpeed;
			float _WindDirection;
			float _WindLineTilling;
			float _WindLineDirection;
			float _WindLineIntensity;
			float _ColorGradient;
			float _ColorGradientScale;
			float _ColorRandomScale;
			float _ColorRandomIntensity;
			float _Alphaclip;
			#ifdef ASE_TESSELLATION
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			TEXTURE2D(_WindLine);
			SAMPLER(sampler_WindLine);
			TEXTURE2D(_Alpha);
			SAMPLER(sampler_Alpha);


			float3 RotateXY165_g5( float3 R, float degrees )
			{
				float3 reflUVW = R;
				half theta = degrees * PI / 180.0f;
				half costha = cos(theta);
				half sintha = sin(theta);
				reflUVW = half3(reflUVW.x * costha - reflUVW.z * sintha, reflUVW.y, reflUVW.x * sintha + reflUVW.z * costha);
				return reflUVW;
			}
			
			float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
			{
				original -= center;
				float C = cos( angle );
				float S = sin( angle );
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
				return mul( finalMatrix, original ) + center;
			}
			

			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 _Vector0 = float3(0,0,1);
				float3 RotateAxis34_g5 = cross( _Vector0 , float3(0,1,0) );
				float3 wind_direction31_g5 = _Vector0;
				float3 wind_speed40_g5 = ( ( _TimeParameters.x * _WindParams.y ) * float3(0.5,-0.5,-0.5) );
				float2 texCoord64 = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord65 = v.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float3 appendResult66 = (float3(-texCoord64.x , texCoord65.x , -texCoord64.y));
				float3 MehsPivotOS69 = appendResult66;
				float3 objToWorld116 = mul( GetObjectToWorldMatrix(), float4( MehsPivotOS69, 1 ) ).xyz;
				float3 vertexToFrag71 = objToWorld116;
				float3 VitualPositionWS72 = vertexToFrag71;
				float3 WorldPosition161_g5 = VitualPositionWS72;
				float3 R165_g5 = WorldPosition161_g5;
				float degrees165_g5 = _WindDirection;
				float3 localRotateXY165_g5 = RotateXY165_g5( R165_g5 , degrees165_g5 );
				float3 temp_cast_0 = (1.0).xxx;
				float3 temp_output_22_0_g5 = abs( ( ( frac( ( ( ( wind_direction31_g5 * wind_speed40_g5 ) + ( localRotateXY165_g5 / _WindParams.w ) ) + 0.5 ) ) * 2.0 ) - temp_cast_0 ) );
				float3 temp_cast_1 = (3.0).xxx;
				float dotResult30_g5 = dot( ( ( temp_output_22_0_g5 * temp_output_22_0_g5 ) * ( temp_cast_1 - ( temp_output_22_0_g5 * 2.0 ) ) ) , wind_direction31_g5 );
				float BigTriangleWave42_g5 = dotResult30_g5;
				float3 temp_cast_2 = (1.0).xxx;
				float3 temp_output_59_0_g5 = abs( ( ( frac( ( ( wind_speed40_g5 + ( localRotateXY165_g5 / _WindParams.z ) ) + 0.5 ) ) * 2.0 ) - temp_cast_2 ) );
				float3 temp_cast_3 = (3.0).xxx;
				float SmallTriangleWave52_g5 = distance( ( ( temp_output_59_0_g5 * temp_output_59_0_g5 ) * ( temp_cast_3 - ( temp_output_59_0_g5 * 2.0 ) ) ) , float3(0,0,0) );
				float3 rotatedValue72_g5 = RotateAroundAxis( ( float3( 0,0,0 ) - float3(0,0.1,0) ), WorldPosition161_g5, normalize( RotateAxis34_g5 ), ( ( BigTriangleWave42_g5 + SmallTriangleWave52_g5 ) * ( 2.0 * PI ) ) );
				float2 texCoord21 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float VerticalFade22 = texCoord21.y;
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float2 WorldUV122 = (ase_worldPos).xz;
				float cos49 = cos( ( _WindLineDirection * 3.141593 ) );
				float sin49 = sin( ( _WindLineDirection * 3.141593 ) );
				float2 rotator49 = mul( ( WorldUV122 / _WindLineTilling ) - float2( 0,0 ) , float2x2( cos49 , -sin49 , sin49 , cos49 )) + float2( 0,0 );
				float mulTime56 = _TimeParameters.x * 0.1;
				float WindMask118 = SAMPLE_TEXTURE2D_LOD( _WindLine, sampler_WindLine, ( rotator49 + frac( ( _WindLineSpeed * mulTime56 ) ) ), 0.0 ).r;
				float3 worldToObj90 = mul( GetWorldToObjectMatrix(), float4( ( ( ( ( rotatedValue72_g5 * float3(1,0,1) ) - WorldPosition161_g5 ) * ( VerticalFade22 * VerticalFade22 ) * ( saturate( pow( abs( WindMask118 ) , 2.0 ) ) * _WindLineIntensity * _WindParams.x ) * 0.1 ) + ase_worldPos ), 1 ) ).xyz;
				float3 FinalVertexOffset93 = worldToObj90;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif

				float3 vertexValue = FinalVertexOffset93;

				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord : TEXCOORD0;

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
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord3 = v.ase_texcoord3;
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord3 = patch[0].ase_texcoord3 * bary.x + patch[1].ase_texcoord3 * bary.y + patch[2].ase_texcoord3 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				float2 uv_Alpha38 = IN.ase_texcoord2.xy;
				float Grass_alpha39 = SAMPLE_TEXTURE2D( _Alpha, sampler_Alpha, uv_Alpha38 ).a;
				

				float Alpha = Grass_alpha39;
				float AlphaClipThreshold = _Alphaclip;

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

		/*ase_pass*/
		Pass
		{
			PackageRequirements
			{
				"com.unity.render-pipelines.universal": "unity=[2022.3.10,2022.3.45]"
			}

			
			Name "GBuffer"
			Tags 
			{
				"LightMode" = "UniversalGBuffer" 
			}

			HLSLPROGRAM
			/*ase_pragma_before*/
			#pragma exclude_renderers gles3 glcore

			#pragma vertex UnlitPassVertex
			#pragma fragment UnlitPassFragment

			//#pragma shader_feature_local_fragment _ALPHATEST_ON
			//#pragma shader_feature_local_fragment _ALPHAMODULATE_ON

			//#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

			#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitGBufferPass.hlsl"

			/*ase_pragma*/

			/*ase_globals*/

			/*ase_funcs*/

			ENDHLSL
		}
		
	}
	
	CustomEditor "ASEMaterialInspector"
	FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19201
Node;AmplifyShaderEditor.CommentaryNode;140;1718.782,-382.7533;Inherit;False;1545.645;323.3746;Comment;7;131;138;142;135;136;137;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;133;128.4483,-583.1345;Inherit;False;1319.937;277;Comment;7;128;123;127;121;130;126;132;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;105;1664,672;Inherit;False;1299.136;397.178;Comment;11;110;109;96;102;104;99;101;103;100;98;37;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;94;-2014.921,918.1791;Inherit;False;1799.184;655.3781;Comment;12;93;153;90;76;77;87;89;144;120;117;82;85;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;73;-2016.496,550.1785;Inherit;False;1627.202;353.9079;Comment;9;64;65;67;68;66;69;71;72;116;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;63;-2017.552,-43.149;Inherit;False;2616.295;569.2615;Comment;29;61;59;118;44;62;115;60;55;49;58;157;56;57;122;46;45;50;54;53;47;48;9;8;7;6;5;4;3;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;42;-2017.388,-592.062;Inherit;False;2126.435;528.2632;Comment;17;36;114;113;112;21;22;33;35;26;25;24;28;30;32;34;31;27;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;41;-2016.727,-885.7163;Inherit;False;591.7714;277;Comment;2;38;39;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;True;False;False;False;False;0;False;;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;True;1;LightMode=DepthOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;6;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;7;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;8;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=DepthNormalsOnly;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.NegateNode;67;-1714.294,624.4199;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;68;-1714.294,695.4199;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;66;-1508.294,720.4199;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-1327.294,720.4199;Inherit;False;MehsPivotOS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexToFragmentNode;71;-859.2941,720.4198;Inherit;False;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;-631.2941,720.4198;Inherit;False;VitualPositionWS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;1744,720;Inherit;False;138;GrassColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;2000,720;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;100;2000,816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;1968,960;Inherit;False;138;GrassColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;2192,864;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;2384,720;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-1666.955,-741.3124;Inherit;False;Grass alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;102;1904,896;Inherit;False;World;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;96;1712,800;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;109;2384,832;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;2592,720;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;2752,720;Inherit;False;FinalColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-996.5331,-199.3726;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;31;-834.4337,-199.589;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;34;-637.1853,-385.8592;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;32;-899.1854,-361.8592;Inherit;False;Property;_TopColor;Top Color;1;0;Create;True;0;0;0;False;0;False;0.5960785,0.7843138,0.09411766,1;0.7220091,0.8962264,0.25083,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;30;-1152.377,-175.9662;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1389.024,-176.2073;Inherit;False;Property;_ColorGradientScale;Color Gradient Scale;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;-1361.937,-271.7009;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1671.576,-247.866;Inherit;False;Property;_ColorGradient;Color Gradient;3;0;Create;True;0;0;0;False;0;False;1;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;26;-1183.304,-271.701;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;35;-472.3295,-385.6008;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;33;-932.1857,-524.8596;Inherit;False;Property;_BottomColor;Bottom Color;2;0;Create;True;0;0;0;False;0;False;0.2431373,0.3411765,0.04705883,1;0.4089924,0.5566037,0.1137707,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-1738.095,-321.4579;Inherit;False;VerticalFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-1969.095,-368.4579;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.AbsOpNode;112;-1511.464,-321.4005;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-473.4337,-313.9208;Inherit;False;62;WindLineColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;-236.4337,-384.9209;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;64;-1966.496,600.1785;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;65;-1966.294,720.4199;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;116;-1091.53,720.767;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;45;-1987,6.851031;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;46;-1794,6.851046;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;122;-1629.77,7.040089;Inherit;False;WorldUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;407.4487,-442.7025;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;375.3494,-510.0978;Inherit;False;122;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;127;582.4489,-509.7023;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;130;1043.448,-532.7023;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;126;178.4483,-442.7025;Inherit;False;Property;_ColorRandomScale;Color Random Scale;16;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;132;1206.384,-532.6647;Inherit;False;RandomColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-100.3293,-384.6008;Inherit;False;BaseColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;1774.633,-332.3612;Inherit;False;36;BaseColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;1984.688,-278.2934;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;136;2272.689,-332.2936;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;135;1743.065,-254.7784;Inherit;False;132;RandomColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;142;1806.789,-182.0466;Inherit;False;Constant;_Float2;Float 2;16;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;138;2436.731,-332.6256;Inherit;False;GrassColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;131;1984,-160;Inherit;False;Property;_ColorRandomIntensity;Color Random Intensity;15;0;Create;True;0;0;0;False;0;False;0;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;121;743.7813,-533.1345;Inherit;True;Property;_ColorRandom;Color Random;14;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;be5ed26ad70e93d4280c3ee193ccd167;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;38;-1966.727,-835.7163;Inherit;True;Property;_Alpha;Alpha;0;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;3ae725f497f157a47afd25a92165c2c1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;672,944;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;13;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;0;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;672,944;Float;False;True;-1;2;ASEMaterialInspector;0;13;Gass_URP;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;False;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;UniversalMaterialType=Unlit;True;5;True;1;d3d11;0;False;True;1;1;False;;0;False;;1;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;False;;True;3;False;;True;False;0;False;;0;False;;True;1;LightMode=UniversalForwardOnly;False;False;0;;0;0;Standard;23;Surface;0;0;  Blend;0;0;Two Sided;0;638313151740687814;Forward Only;1;638313132156672889;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;638313176091554110;LOD CrossFade;0;638313132057156468;Built-in Fog;0;638313132111147425;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Vertex Position,InvertActionOnDeselection;1;638313176006791653;0;10;False;True;True;True;False;False;False;False;False;False;False;;True;0
Node;AmplifyShaderEditor.FunctionNode;144;-1296,1120;Inherit;False;GrassWind;-1;;5;daa13501c3c3a6a4ba9f9777c1d8f165;0;7;158;FLOAT;1;False;167;FLOAT;0;False;160;FLOAT;1;False;1;FLOAT;1;False;157;FLOAT;2;False;156;FLOAT;10;False;147;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;89;-1168,1328;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;87;-1840,1424;Inherit;False;72;VitualPositionWS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1776,976;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-1968,976;Inherit;False;22;VerticalFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;90;-832,1120;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;153;-944,1120;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-608,1120;Inherit;False;FinalVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;43;0,992;Inherit;False;Property;_Alphaclip;Alpha clip;5;0;Create;True;0;0;0;False;0;False;0.35;0.333;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;272,960;Inherit;False;39;Grass alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;416,1056;Inherit;False;93;FinalVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;448,928;Inherit;False;104;FinalColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-1904,1200;Inherit;False;Property;_WindLineIntensity;WindLine Intensity;11;0;Create;True;0;0;0;False;0;False;0.6;1;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-1600,1168;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-1904,1072;Inherit;False;Property;_WindDirection;WindDirection;12;0;Create;True;0;0;0;False;0;False;45;0;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;85;-1840,1264;Inherit;False;Property;_WindParams;Wind Params;13;1;[Header];Create;True;1;Intensity(x)Speed(y)MinScale(z)MaxScale(w);0;0;False;1;Space(10);False;0.2,0.3,4,10;1,0.5,4,10;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;156;-2529.412,1089.375;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;151;-3200,832;Inherit;True;FLOAT;0;1;2;3;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-3120,1152;Inherit;False;118;WindMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;155;-2928,1152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;154;-2736,1152;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-1600,80;Inherit;False;Property;_WindLineTilling;WindLine Tilling;8;0;Create;True;0;0;0;False;0;False;1;500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;47;-1392,48;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1392,144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1696,144;Inherit;False;Property;_WindLineDirection;WindLine Direction;9;0;Create;True;0;0;0;False;0;False;0;0.41;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-1600,208;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;3.141593;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;49;-1216,96;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;57;-1520,288;Inherit;False;Property;_WindLineSpeed;WindLine Speed;10;0;Create;True;0;0;0;False;0;False;0,0.3;0,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;56;-1488,400;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;157;-1152,288;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1296,288;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-992,96;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;44;-880,96;Inherit;True;Property;_WindLine;WindLine;6;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;2b9f81a91733f254ab562ce913cb295b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-592,96;Inherit;False;WindMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;59;-592,160;Inherit;False;Property;_WindLineColor;WindLine Color;7;0;Create;True;0;0;0;False;0;False;0.6832584,0.8584906,0.2159724,1;0.8222025,1,0.1477984,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;61;-560,320;Inherit;False;22;VerticalFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;115;-176,96;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-16,96;Inherit;False;WindLineColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-336,96;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
WireConnection;67;0;64;1
WireConnection;68;0;64;2
WireConnection;66;0;67;0
WireConnection;66;1;65;1
WireConnection;66;2;68;0
WireConnection;69;0;66;0
WireConnection;71;0;116;0
WireConnection;72;0;71;0
WireConnection;98;0;37;0
WireConnection;98;1;96;0
WireConnection;100;0;96;0
WireConnection;101;0;100;0
WireConnection;101;1;102;0
WireConnection;101;2;103;0
WireConnection;99;0;98;0
WireConnection;99;1;101;0
WireConnection;39;0;38;4
WireConnection;110;0;99;0
WireConnection;110;1;109;1
WireConnection;104;0;110;0
WireConnection;27;0;26;0
WireConnection;27;1;30;0
WireConnection;31;0;27;0
WireConnection;34;0;33;0
WireConnection;34;1;32;0
WireConnection;34;2;31;0
WireConnection;30;0;28;0
WireConnection;24;0;112;0
WireConnection;24;1;25;0
WireConnection;26;0;24;0
WireConnection;35;0;34;0
WireConnection;22;0;21;2
WireConnection;112;0;22;0
WireConnection;114;0;35;0
WireConnection;114;1;113;0
WireConnection;116;0;69;0
WireConnection;46;0;45;0
WireConnection;122;0;46;0
WireConnection;128;0;126;0
WireConnection;127;0;123;0
WireConnection;127;1;128;0
WireConnection;130;0;121;0
WireConnection;132;0;130;0
WireConnection;36;0;114;0
WireConnection;137;0;134;0
WireConnection;137;1;135;0
WireConnection;137;2;142;0
WireConnection;136;0;134;0
WireConnection;136;1;137;0
WireConnection;136;2;131;0
WireConnection;138;0;136;0
WireConnection;121;1;127;0
WireConnection;1;2;106;0
WireConnection;1;3;40;0
WireConnection;1;4;43;0
WireConnection;1;5;95;0
WireConnection;144;158;77;0
WireConnection;144;167;82;0
WireConnection;144;160;117;0
WireConnection;144;1;85;2
WireConnection;144;157;85;3
WireConnection;144;156;85;4
WireConnection;144;147;87;0
WireConnection;77;0;76;0
WireConnection;77;1;76;0
WireConnection;90;0;153;0
WireConnection;153;0;144;0
WireConnection;153;1;89;0
WireConnection;93;0;90;0
WireConnection;117;0;156;0
WireConnection;117;1;120;0
WireConnection;117;2;85;1
WireConnection;156;0;154;0
WireConnection;151;0;119;0
WireConnection;155;0;119;0
WireConnection;154;0;155;0
WireConnection;47;0;122;0
WireConnection;47;1;48;0
WireConnection;54;0;50;0
WireConnection;54;1;53;0
WireConnection;49;0;47;0
WireConnection;49;2;54;0
WireConnection;157;0;58;0
WireConnection;58;0;57;0
WireConnection;58;1;56;0
WireConnection;55;0;49;0
WireConnection;55;1;157;0
WireConnection;44;1;55;0
WireConnection;118;0;44;1
WireConnection;115;0;60;0
WireConnection;62;0;115;0
WireConnection;60;0;118;0
WireConnection;60;1;59;0
WireConnection;60;2;61;0
ASEEND*/
//CHKSM=15FEFE65219C2D0CC90B366C0415E28F095333FD