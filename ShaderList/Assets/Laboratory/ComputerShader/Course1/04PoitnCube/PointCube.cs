using UnityEngine;
using System.Collections;

public class PointCube: MonoBehaviour {
    public Transform target;
    public ComputeShader comshader;             
    private ComputeBuffer buffer;          
    public Material mat;
    private int number = 512 * 8 * 8 * 8;    
    int kernel;


    // Use this for initialization
    void Start()
    {
        buffer = new ComputeBuffer(number, 12); //设置P Buffer的大小,12为字节大小(float3),线程组32*32*1；每组线程4*4*1；12是结构体的字节数
        kernel = comshader.FindKernel("Main");//找到Main的id号
    }

    private void Update()
    {
        comshader.SetFloat("x", target.position.x);
        comshader.SetFloat("y", target.position.y);
        comshader.SetFloat("z", target.position.z);
    }

    private void OnRenderObject()
    {
        comshader.SetBuffer(kernel, "Result", buffer);//给compute shader设置P
        comshader.Dispatch(kernel, 8,8,8);

        //buffer传递给其他的shader使用
        mat.SetBuffer("points", buffer); //给shader设置P
        mat.SetPass(0);//指定shader的pass渲染
        Graphics.DrawProcedural(MeshTopology.Points, number);//在屏幕绘制点
    }

    private void OnDestroy()
    {
        buffer.Release();//释放buffer
    }



}
