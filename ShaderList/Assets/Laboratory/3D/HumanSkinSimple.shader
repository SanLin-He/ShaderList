Shader "Custom/HumanSkinSimple" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_RimLightingColor ("Rim Color", Color) = (0.26,0.19,0.16,0.0)
		_RimLightingPower("Rim Diffuse Power", Float) = 3
		_WrappedDiffuseTint ("Wrapped Diffuse Color", Color) = (0.26,0.19,0.16,0.0)
		_WrappedDiffusePower("Wrapped Diffuse Power", Float) = 2
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
    CGPROGRAM
    #pragma surface surf WrapLambert


	//将漫反射照明微微延伸到物体的背面，模拟次表面散射
	uniform fixed4 _WrappedDiffuseTint;
	uniform float  _WrappedDiffusePower;

    half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half atten) {
        half NdotL = dot (s.Normal, lightDir);
        fixed3 remappedNdotL = (NdotL + _WrappedDiffuseTint.xyz) /(_WrappedDiffuseTint.xyz + 1);
		fixed3 diff = pow(max(remappedNdotL, 0), _WrappedDiffusePower);	
		//half diff = NdotL * 0.5 + 0.5;
        half4 c;
        c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
        c.a = s.Alpha;
        return c;
    }

    struct Input {
        float2 uv_MainTex;
        float3 viewDir;
    };
    
    sampler2D _MainTex;
    fixed4 _RimLightingColor;
	float _RimLightingPower;
    void surf (Input IN, inout SurfaceOutput o) {
        float3 nV   = normalize(IN.viewDir);
		float NdotV = max(dot(nV, o.Normal), 0);
		fixed f     = pow(1 - NdotV, _RimLightingPower);
        o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
		o.Emission  = _RimLightingColor.rgb * (_RimLightingColor.a * f);//表面rim发光模拟次表面散射

    }
    ENDCG
	} 
	FallBack "Diffuse"
}
