using UnityEngine;
using System.Collections;

public class PointPicture : MonoBehaviour {

    public ComputeShader comshader;   
             
    private ComputeBuffer buffer;          
    public Material mat;              
    int kernel;


    // Use this for initialization
    void Start()
    {
        buffer = new ComputeBuffer(16384, 12); //设置P Buffer的大小,12为字节大小(float3),线程组32*32*1；每组线程4*4*1；12是结构体的字节数
        kernel = comshader.FindKernel("Main");//找到Main的id号
    }

    private void OnRenderObject()
    {
        comshader.SetBuffer(kernel, "P", buffer);//给compute shader设置P
        comshader.Dispatch(kernel, 32, 32, 1);

        //buffer传递给其他的shader使用
        mat.SetBuffer("P", buffer); //给shader设置P
        mat.SetPass(0);//指定shader的pass渲染
        Graphics.DrawProcedural(MeshTopology.LineStrip, 16384);//在屏幕绘制点
    }

    private void OnDestroy()
    {
        buffer.Release();//释放buffer
    }



}
