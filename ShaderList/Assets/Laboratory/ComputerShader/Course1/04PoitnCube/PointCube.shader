Shader "CustomerComputer/PointCube"
{
	 Properties {
        _MainCUBE ("Base (RGB)", Cube) = "white" {} 
    }                                            
                                                 

    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass{

            Blend Off 
			Lighting Off 
			Cull Off 
			ZWrite Off 
			ZTest Off 
			AlphaTest Off
			
			
            CGPROGRAM
            #pragma target 5.0
            #pragma vertex vert 
            #pragma fragment frag 
            #include "UnityCG.cginc"

            StructuredBuffer<float3> points;//存有点位置
            //sampler2D _MainTex;
			samplerCUBE _MainCUBE;
            struct vertIN{
                uint id : SV_VertexID;
            };

            struct vertOUT{
                float4 pos : SV_POSITION;
                float3 uv : TEXCOORD0;
            };

            vertOUT vert(vertIN i){
               vertOUT o;
               float3 pos= points[i.id]; //存储点的位置,points buffer中在compute shader以放置了点位置
			   float4 position = float4(pos ,1);
               o.pos = mul(UNITY_MATRIX_VP,position); //因为p中的是世界坐标pos从世界坐标变换到视平空间
			   fixed3 n = fixed3(1,0,0);
			   if(position.z == 0){
						n = fixed3(0,0,1);
			   }
			    float3 viewDir = normalize(WorldSpaceViewDir(position));
				o.uv = reflect(-viewDir, n);
               //o.uv = points[i.id]/64; //把uv值确定在（0，1）的区间内
               return o;
            }

            fixed4 frag(vertOUT ou):COLOR{
				
               //fixed4 c = fixed4(ou.uv,1);
               fixed4 c = texCUBE(_MainCUBE,ou.uv);

                return c;

            }
            ENDCG
        }
    } 
    FallBack "Diffuse"
}
