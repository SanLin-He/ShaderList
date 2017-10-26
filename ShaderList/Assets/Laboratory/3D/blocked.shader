// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/blocked" 
{
	// Unlit shader. Simplest possible textured shader.
	// - no lighting
	// - no lightmap support
	// - no per-material color

	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_RimColor ("Rim Color", Color) = (0.26,0.19,0.16,0.0)
		_RimPower ("Rim Power", Range(0.2,3.0)) = 1.0
	}

	SubShader 
	{

		//Background: 1000
		//Geometry: 2000
		//AlphaTest: 2450
		//Transparent: 3000
		//Overlay: 4000
		Tags { "RenderType"="Opaque" "Queue"="Transparent-20" }	
		
		
		Pass {
		
			ZTest greater//当被遮挡时渲染
			ZWrite off//不跟新深度缓存
	
			CGPROGRAM
	
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest 
			
			#include "UnityCG.cginc"		
			
			uniform float4 _RimColor;
    		uniform float _RimPower;
    
			struct v2f_full
			{
				half4 pos : POSITION;
				half3 norm : TEXCOORD0;
				half3 viewDir : TEXCOORD2;
			};
			
			v2f_full vert (appdata_full v)
			{
				v2f_full o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				half3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				half3 worldNormal = mul((half3x3)unity_ObjectToWorld, v.normal.xyz);
				
				o.norm = worldNormal;
				o.viewDir = (_WorldSpaceCameraPos.xyz - worldPos);		
				
				return o; 
			}
			
			fixed4 frag (v2f_full i) : COLOR 
			{					
				half4 outColor = _RimColor;
    
    			float3 N = normalize(i.norm); 
    			float3 V = normalize(i.viewDir);
    			float rim = 1.0 - saturate(dot(N,V));
    
    			return outColor * pow(rim, _RimPower);
			}
			
			ENDCG
		}
			
		Pass {  
			ZTest less//不被遮挡时渲染
			ZWrite on//写深度缓存
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.texcoord);
				return col;
			}
		ENDCG
	}
	
	}

}
