// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Projective-Texture-Mapping" {
    Properties {
        _Tex ("Proj Tex", 2D) = "white" {}
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _Ck ("Color Coef", float) = 1
    }
    SubShader {
        Pass {
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _Tex;
            float4 _Color;
            float _Ck;
            float4x4 _texProjMat;

            struct v2f {
                float4 pos : POSITION;
                float4 shadowUV : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 light : TEXCOORD2;
            };

            v2f vert(appdata_base v) {
                v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				
                o.shadowUV = mul(_texProjMat, worldPos);
                o.normal = v.normal;
                o.light = ObjSpaceLightDir(v.vertex);
                
                return o;
            }

            float4 frag(v2f i) : COLOR {
                float nl = dot(i.normal, i.light);

                //float2 uv = float2(i.shadowUV.x, i.shadowUV.y) / i.shadowUV.w * 0.5 + 0.5;//归一化
                //if (uv.x < 0 || uv.x > 1 || uv.y < 0 || uv.y > 1)
                //    return _Ck * _Color * max(0, nl);

                //float4 t = tex2D(_Tex, uv);

                float4 t = tex2Dproj(_Tex, (i.shadowUV * 0.5 + 0.5));


                return _Ck * t * _Color * max(0, nl);
            }

            ENDCG
        }
    } 
    FallBack "Diffuse"
}