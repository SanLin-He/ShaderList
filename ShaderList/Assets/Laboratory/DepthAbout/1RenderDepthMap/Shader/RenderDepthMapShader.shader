/*
	created by chenjd
	http://www.cnblogs.com/murongxiaopifu/
*/
Shader "chenjd/RenderDepthMapShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
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
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;//来获取摄像机保存的场景的深度信息
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);//矩阵坐标转换
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//利用UNITY_SAMPLE_DEPTH这个宏来处理_CameraDepthTexture的值
				//样就获取了某个像素的深度值
				float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
				//另一个内建的方法Linear01Depth将结果转化为线性的
				float linear01Depth = Linear01Depth(depth);
				return linear01Depth;
			}

			ENDCG
		}
	}
}
