﻿Shader "Custom/Reflection" {
	Properties {
	  
	  _Cube ("Cubemap", CUBE) = "" {}
	  _Alpha ("Alpha", Range(0, 1)) = 0.2
	  _ReflectRefractBalance ("Skybox Reflect vs Refract", Range(0, 1)) = 0.0
	  _WaveHeight ("Wave Height", Float) = 0.1
	  _WaveSpeed ("Wave Speed", Float) = 1
	}
	 SubShader
	{
		Pass
		{
			// The following 3 lines are thanks to https://unity3d.com/learn/tutorials/topics/graphics/making-transparent-shader
			Tags {"Queue" = "Transparent" "RenderType" = "Transparent"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			
			uniform float _Alpha;
			uniform float _ReflectRefractBalance;
			uniform float _WaveHeight;
			uniform float _WaveSpeed;
			 
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normalInWorldCoords : NORMAL;
				float3 vertexInWorldCoords : TEXCOORD1;
			};

			v2f vert (appdata v)
			{
				v2f o;

				o.vertexInWorldCoords = mul(unity_ObjectToWorld, v.vertex); //Vertex position in WORLD coords
				o.normalInWorldCoords = UnityObjectToWorldNormal(v.normal); //Normal
				
				// Based off the code from my ol' Phong Bounce
				float4 xyz = float4(
                        v.vertex.x,
                        v.vertex.y + (_WaveHeight*cos(_Time.y*_WaveSpeed + v.vertex.x)),
                        v.vertex.z,
                        1.0
                );
                o.vertex = UnityObjectToClipPos(xyz); 
				
				
				return o;
			}
			
			samplerCUBE _Cube;
			
			fixed4 frag (v2f i) : SV_Target
			{
			
			 float3 P = i.vertexInWorldCoords.xyz;
			 
			 //get normalized incident ray (from camera to vertex)
			 float3 vIncident = normalize(P - _WorldSpaceCameraPos);
			 
			 //reflect that ray around the normal using built-in HLSL command
			 float3 vReflect = reflect( vIncident, i.normalInWorldCoords );
			 
			 
			 //use the reflect ray to sample the skybox
			 float4 reflectColor = texCUBE( _Cube, vReflect );

			 
			 
			 //refract the incident ray through the surface using built-in HLSL command
			 float3 vRefract = refract( vIncident, i.normalInWorldCoords, 0.5 );
			 
			 //float4 refractColor = texCUBE( _Cube, vRefract );
			 
			 
			 float3 vRefractRed = refract( vIncident, i.normalInWorldCoords, 0.1 );
			 float3 vRefractGreen = refract( vIncident, i.normalInWorldCoords, 0.4 );
			 float3 vRefractBlue = refract( vIncident, i.normalInWorldCoords, 0.7 );
			 
			 float4 refractColorRed = texCUBE( _Cube, float3( vRefractRed ) );
			 float4 refractColorGreen = texCUBE( _Cube, float3( vRefractGreen ) );
			 float4 refractColorBlue = texCUBE( _Cube, float3( vRefractBlue ) );
			 float4 refractColor = float4(refractColorRed.r, refractColorGreen.g, refractColorBlue.b, 1.0);
			 
			 return float4(lerp(reflectColor, refractColor, _ReflectRefractBalance).rgb, _Alpha);				
				
			}
	  
			ENDCG
		}
	}

	
	SubShader {
	  Tags { "RenderType" = "Opaque" }
	  CGPROGRAM
	  #pragma surface surf Lambert
	  struct Input {
		  float2 uv_MainTex;
		  float3 worldRefl;
	  };
	  sampler2D _MainTex;
	  samplerCUBE _Cube;
	  void surf (Input IN, inout SurfaceOutput o) {
		  o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb * 0.5;
		  o.Emission = texCUBE (_Cube, IN.worldRefl).rgb;
	  }
	  ENDCG
	} 
	Fallback "Diffuse"
  }
