// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/VolumetricRaycasting03"
{
	Properties
	{
		
		_Center("Center", vector) = (0,0,0,0)
		_Radius("Radius", float) = 0.2
		_Color("color",color) = (1,1,1,1)
		_SpecularPower("SpecularPower", range(1,5)) = 2
		_Gloss("Gloss",float) = 0.5
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
			#include "Lighting.cginc"

			

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
			
			fixed4 _Color;
			fixed4 simpleLambert(fixed3 normal)
			{
				fixed3 lightDir = _WorldSpaceLightPos0.xyz;//光的方向
				fixed3 lightCol = _LightColor0.rgb;//光的颜色

				fixed NdotL = max(dot(normal,lightDir),0);
				fixed4 c;
				c.rgb = _Color * lightCol * NdotL;
				c.a = 1;
				return c;
			}
			float _SpecularPower;
			float _Gloss;
			fixed4 simpleSpecular(fixed normal,float3 viewDirection)
			{
				fixed3 lightDir = _WorldSpaceLightPos0.xyz;//光的方向
				fixed3 lightCol = _LightColor0.rgb;//光的颜色
				fixed3 h = (lightDir - viewDirection) / 2.;
				fixed s = pow( dot(normal, h), _SpecularPower) * _Gloss;

				fixed NdotL = max(dot(normal,lightDir),0);
				fixed4 c;
				c.rgb = _Color * lightCol * NdotL + s;
				c.a = 1;	
				return c;
			}
			
			float getDistance(float3 p)
			{
				return distance(p,_Center) - _Radius;
			}
			float3 normal(float3 p)
			{
				const float eps = 0.01;
				return normalize(float3(getDistance(p + float3(eps,0,0)) - getDistance(p - float3(eps,0,0)),
					getDistance(p + float3(0,eps,0)) - getDistance(p - float3(0,eps,0)),//y
					getDistance(p + float3(0,0,eps)) - getDistance(p - float3(0,0,eps))//z
				));
			
			}
			fixed4 renderSurface(float3 p,float3 viewDirection)
			{
				float3 n = normal(p);
				//return simpleLambert(n) ;
				return simpleSpecular(n,viewDirection);
			}

			fixed4 raymarch(float3 position, float3 direction)
			{
				for(int i = 0; i < STEPS;i++)
				{
					float distance = getDistance(position);
					if(distance < MIN_DISTANCE)
						return renderSurface(position,direction);

					position += direction * STEP_SIZE;				
				}
				return 0;
			
			}

		
			fixed4 frag (v2f i) : SV_Target
			{


				float3 worldPosition = i.wPos;
				float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);
				fixed4 c = raymarch(worldPosition,viewDirection);
				clip (c.a - 0.001);//丢弃a <0.001的
				return c;
			}
			ENDCG
		}
	}
}
