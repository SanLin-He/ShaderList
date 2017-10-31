/*
	created by chenjd
	http://www.cnblogs.com/murongxiaopifu/
*/
Shader "chenjd/SeeThroughWall"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_EdgeColor("Edge Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass//被遮挡住的部分
		{
			ZTest Greater//自己的深度比别人的深度大（先渲染，在后面，被遮挡），通过测试，像素不丢弃
			Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;

				//@add
				float3 normal : NORMAL;

			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;

				//@add
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _EdgeColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);//转换到裁剪坐标系
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);//处理uv

				//@add
				o.normal = UnityObjectToWorldNormal(v.normal);//法线转换到世界坐标系
				//_WorldSpaceCameraPos 获取相机的世界坐标
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);//计算视线方向

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float NdotV = 1 - dot(i.normal, i.viewDir) * 1.5;//边缘发光率
				return _EdgeColor * NdotV;
			}
			ENDCG
		}

		Pass//未被遮挡的部分
		{
			ZTest Less //自己的深度比别人的深度小（后渲染，在前面，遮挡别人），通过测试，像素不丢弃

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
