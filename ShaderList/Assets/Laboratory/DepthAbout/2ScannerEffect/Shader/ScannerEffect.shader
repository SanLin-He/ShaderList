/*
	created by chenjd
	http://www.cnblogs.com/murongxiaopifu/
*/
Shader "chenjd/ScannerEffect"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_ScanDistance("Scan Distance", float) = 0
		_ScanWidth("Scan Width", float) = 10
		_ScanColor("Scan Color", Color) = (1, 1, 1, 0)
	}
	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always

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
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv_depth : TEXCOORD1;
			};

			float4 _CameraWS;//相机的世界坐标
			float4 _MainTex_TexelSize;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);//矩阵坐标转换
				o.uv = v.uv.xy;
				o.uv_depth = v.uv.xy;//相同的uv

				return o;
			}

			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;//来获取摄像机保存的场景的深度信息
			float _ScanDistance;
			float _ScanWidth;
			float4 _ScanColor;


			half4 frag (v2f i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);

				//获取深度信息
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
				//利用UNITY_SAMPLE_DEPTH这个宏来处理_CameraDepthTexture的值
				//样就获取了某个像素的深度值
				float linear01Depth = Linear01Depth(depth);


				if (linear01Depth < _ScanDistance && linear01Depth > _ScanDistance - _ScanWidth && linear01Depth < 1)
				{
					float diff = 1 - (_ScanDistance - linear01Depth) / (_ScanWidth);
					_ScanColor *= diff;
					return col + _ScanColor;
				}

				return col;
			}
			ENDCG
		}
	}
}
