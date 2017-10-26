// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/VolumetricRaycasting01"
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
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 pos : SV_POSITION;
				float3 wPos : TEXCOORD1;
			};


			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.wPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			#define STEPS 64
			#define STEP_SIZE 0.01
			float3 _Center;
			float _Radius;
			
			bool isHit(float3 p)
			{
				return distance(p,_Center) < _Radius;
			}

			bool raymarchHit(float3 position, float3 direction)
			{
				for(int i = 0; i < STEPS;i++)
				{
					if(isHit(position))
						return true;

					position += direction * STEP_SIZE;				
				}
				return false;
			
			}

		
			fixed4 frag (v2f i) : SV_Target
			{
				UNITY_APPLY_FOG(i.fogCoord, col);

				float3 worldPosition = i.wPos;
				float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);
				if(raymarchHit(worldPosition,viewDirection))
					return fixed4(1,0,0,1);
				else 
					return fixed4(0,1,1,0);
			}
			ENDCG
		}
	}
}
