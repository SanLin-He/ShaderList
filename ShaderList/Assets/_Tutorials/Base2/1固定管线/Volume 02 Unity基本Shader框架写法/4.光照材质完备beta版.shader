

Shader "浅墨Shader编程/4.光照材质完备beta版Shader" 
{
	//-------------------------------【属性】-----------------------------------------
    Properties
	{
        _Color ("主颜色", Color) = (1,1,1,0)
		 _Ambient ("环境颜色", Color) = (1,1,1,0)
        _SpecColor ("反射高光颜色", Color) = (1,1,1,1)
        _Emission ("自发光颜色", Color) = (0,0,0,0)
        _Shininess ("光泽度", Range (0.01, 1)) = 0.7

		  //  _WaveScale ("Wave scale", Range (0.02,0.15)) = 0.07 // sliders
    //_ReflDistort ("Reflection distort", Range (0,1.5)) = 0.5
    //_RefrDistort ("Refraction distort", Range (0,1.5)) = 0.4
    //_RefrColor ("Refraction color", Color) = (.34, .85, .92, 1) // color
    //_ReflectionTex ("Environment Reflection", 2D) = "" {} // textures
    //_RefractionTex ("Environment Refraction", 2D) = "" {}
    //_Fresnel ("Fresnel (A) ", 2D) = "" {}
    //_BumpMap ("Bumpmap (RGB) ", 2D) = "" {}
    }

	//---------------------------------【子着色器】----------------------------------
    SubShader 
	{
		//----------------通道---------------
        Pass 
		{
			//-----------材质------------
            Material 
			{
				////可调节的漫反射光和环境光反射颜色
    //            Diffuse [_Color]
    //           // Ambient [_Color]
				////光泽度
    //            Shininess [_Shininess]
				////高光颜色
    //            Specular [_SpecColor]
				////自发光颜色
    //            Emission [_Emission]

				diffuse[_Color]
                ambient[_Ambient]
                specular[_Specular]
                shininess[_Shininess]
                emission[_Emission]
            }
			//开启光照
            Lighting On
			separatespecular on  // 镜面高光
        }
    }
}
