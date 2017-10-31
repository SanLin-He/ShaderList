using UnityEngine;
using System.Collections;
using UnityEditor;

[ExecuteInEditMode]
public class RenderDepthMap : MonoBehaviour {

    public Material mat;

	// Use this for initialization
	void Start () {
        //手动让相机提供深度信息（如果在延迟渲染路径（Deferred Lighting）下，
        //由于延迟渲染需要场景的深度信息和法线信息来做光照计算，所以并不需要我们手动设置相机）
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
        //这样我们就可以在shader中访问 _CameraDepthTexture 来获取保存的场景的深度信息，
        //之后再利用UNITY_SAMPLE_DEPTH这个宏来处理_CameraDepthTexture的值，这样我们就获取了某个像素的深度值。
    }

    void OnRenderImage(RenderTexture src, RenderTexture des)
    {
        Graphics.Blit(src, des, mat);
    }

    // Update is called once per frame
    void Update () {
	
	}
}
