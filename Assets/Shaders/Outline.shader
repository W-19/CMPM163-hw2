Shader "Custom/Outline"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_Outline("Outline", Float) = 0
	}
	SubShader
	{
		Pass
		{

			Cull Front

			CGPROGRAM
		
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform sampler _MainTex;
			uniform float _Outline;

			struct appdata{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0; 
			};

			struct v2f{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(appdata v){
				v2f o;
				v.vertex += float4(v.normal, 1.0) * _Outline;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				float4 c = tex2D(_MainTex, i.uv);
				return float4(0,0,0,0);
			}

			ENDCG
		}

		Pass
		{

			CGPROGRAM
		
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform float _Outline;

			struct appdata{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0; 
			};

			struct v2f{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler _MainTex;

			v2f vert(appdata v){
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				float4 c = tex2D(_MainTex, i.uv);
				return float4(1,1,1,1);
			}

			ENDCG
		}
		
	}
	FallBack "Diffuse"
}
