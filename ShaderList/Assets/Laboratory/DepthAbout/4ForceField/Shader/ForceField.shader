//1.半透明效果
//2.一个和观察方向相关的描边效果
//3.相交高亮，主要指能量场和别的物体相交的地方是高亮显示
	//所谓的相交高亮指的是能量场和别的物体相交时，在相交处绘制出高亮效果。这时我们就要用到深度信息了。
	//当能量场和某个物体相交时，二者的深度信息应该一致，基于这个对比深度信息，我们可以用来估计一个像素的“相交程度”。
//4.表面扭曲
Shader "chenjd/ForceField"
{
	Properties
{
	_Color("Color", Color) = (0,0,0,0)//能两场颜色
	_NoiseTex("NoiseTexture", 2D) = "white" {}//能两场扭曲噪声
	_DistortStrength("DistortStrength", Range(0,1)) = 0.2//扭曲程度
	_DistortTimeFactor("DistortTimeFactor", Range(0,1)) = 0.2//扭曲时间动态因子
	_RimStrength("RimStrength",Range(0, 10)) = 2//外发光强度
	_IntersectPower("IntersectPower", Range(0, 3)) = 2//相交强度
}

	SubShader
{
	//1.-------首先我们要开启透明混合并指定渲染队列为透明
	ZWrite Off
	Cull Off
	Blend SrcAlpha OneMinusSrcAlpha

	Tags
	{
		"RenderType" = "Transparent"
		"Queue" = "Transparent"
	}
	//1.-------end

	//4.1......需要一张渲染能量场之前的场景的渲染图
	GrabPass
	{
		"_GrabTempTex"
	}
	//4.1......end

		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
				float4 grabPos : TEXCOORD2;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD3;
			};

			sampler2D _GrabTempTex;
			float4 _GrabTempTex_ST;
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _DistortStrength;
			float _DistortTimeFactor;
			float _RimStrength;
			float _IntersectPower;

			//需要注意的是，能量场的shader在执行时_CameraDepthTexture中只保存了场景中不透明物体的深度信息，
			//因此这个时候无法从CameraDepthTexture中获取能量场的深度信息，所以要在vert中计算顶点的深度
			sampler2D _CameraDepthTexture;//来获取摄像机保存的场景的深度信息

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);//左边转换

				//2.1------根据观察方向绘制能量场的边缘
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex)));
				//2.1------end

				//3.1----因此这个时候无法从CameraDepthTexture中获取能量场的深度信息，所以要在vert中计算顶点的深度，这里我利用了COMPUTE_EYEDEPTH这个内置的宏
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.screenPos.z);
				//3.1----end


				//4.1----扭曲的图片
				o.grabPos = ComputeGrabScreenPos(o.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
				//4.1----end


				return o;
			}

			fixed4 _Color;


			fixed4 frag(v2f i) : SV_Target
			{
				//2.2------根据观察方向绘制能量场的边缘
				//圆环
				float3 viewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, i.vertex)));
				float rim = 1 - abs(dot(i.normal, normalize(i.viewDir))) * _RimStrength;
				//2.2------end

				//3.2----获取场景和能量场当前片元的深度了
				//获取已有的深度信息,此时的深度图里没有力场的信息
				//判断相交
				float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
				float partZ = i.screenPos.z;
				//两者相减就是深度的差异diff，再用1 - diff就得到了一个“相交程度”。
				float diff = sceneZ - partZ;
				float intersect = (1 - diff) * _IntersectPower;
				//3.2----end


				//4.2----- 扭曲
				//扭曲
				float4 offset = tex2D(_NoiseTex, i.uv - _Time.xy * _DistortTimeFactor);
				i.grabPos.xy -= offset.xy * _DistortStrength;
				fixed4 color = tex2Dproj(_GrabTempTex, i.grabPos);
				//4.2-----end

				//计算最终颜色输出
				float glow = max(intersect, rim);
				fixed4 col = _Color * glow + color;
				return col;

			}

			ENDCG
		}
}
}