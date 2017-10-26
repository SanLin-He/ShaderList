// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/VolumetricRaycasting02"
{
	Properties
	{
		
		_Center("Center", vector) = (0,0,0,0)
		_Radius("Radius", float) = 0.2
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
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
				float4 pos : SV_POSITION;
				float3 wPos : TEXCOORD1;
			};


			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.wPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				return o;
			}

			#define STEPS 64
			#define STEP_SIZE 0.01
			#define MIN_DISTANCE 0.01
			float3 _Center;
			float _Radius;
			
			float getDistance(float3 p)
			{
				return distance(p,_Center) - _Radius;
			}

			fixed4 raymarch(float3 position, float3 direction)
			{
				for(int i = 0; i < STEPS;i++)
				{
					float distance = getDistance(position);
					if(distance < MIN_DISTANCE)
						return i /(float)STEPS;//渐变色

					position += direction * STEP_SIZE;				
				}
				return 1;//黑色
			
			}

		
			fixed4 frag (v2f i) : SV_Target
			{


				float3 worldPosition = i.wPos;
				float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);
				return raymarch(worldPosition,viewDirection);
			}
			ENDCG
		}
	}
}
