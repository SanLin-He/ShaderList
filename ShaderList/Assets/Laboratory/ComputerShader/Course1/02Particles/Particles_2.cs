using UnityEngine;
using System.Collections;
using System.Collections.Generic;

//Buffer数据结构
struct PBuffer
{
    //size 40
    public float life;//4
    public Vector3 pos;//4x3
    public Vector3 scale;//4x3
    public Vector3 eulerAngle;//4x3
};

public class Particles_2 : MonoBehaviour
{
    public ComputeShader shader;
    public GameObject prefab;
    private List<GameObject> pool = new List<GameObject>();
    int count = 16; //count数组的长度（等于2个三维的积 2x2x1 * 2x2x1）线程组的个数乘以每个线程组中线程的个数
    private ComputeBuffer buffer;

    void Start()
    {
        for (int i = 0; i <count; i++) {
            GameObject obj = Instantiate(prefab) as GameObject;
            pool.Add(obj);
        }
        CreateBuffer();
    }

    void CreateBuffer()
    {
        //count数组的长度（等于2个三维的积 2x2x1 * 2x2x1），40是结构体的字节长度
        buffer = new ComputeBuffer(count, 40);
        PBuffer[] values = new PBuffer[count];
        for (int i = 0; i < count; i++)
        {
            PBuffer m = new PBuffer();
            InitStruct(ref m);
            values[i] = m;
        }
        // 初始化结构体并赋予buffer
        buffer.SetData(values);
    }

    void InitStruct(ref PBuffer m)
    {
        m.life = Random.Range(1f, 3f);
        m.pos = Random.insideUnitSphere * 5f;
        m.scale = Vector3.one * Random.Range(0.3f, 1f);
        m.eulerAngle = new Vector3(0, Random.Range(0f, 180f), 0);
    }

    void Update()
    {
        //运行Shader
        Dispatch();

        //根据Shader返回的buffer数据更新物体信息
        PBuffer[] values = new PBuffer[count];
        buffer.GetData(values);
        bool reborn = false;
        for (int i = 0; i < count; i++)
        {
            if (values[i].life < 0)
            {
                InitStruct(ref values[i]);
                reborn = true;
            }
            else
            {
                pool[i].transform.position = values[i].pos;
                pool[i].transform.localScale = values[i].scale;
                pool[i].transform.eulerAngles = values[i].eulerAngle;
                //pool [i].GetComponent<</span>MeshRenderer>().material.SetColor ("_TintColor", new Color(1,1,1,values [i].life));
            }
        }
        if (reborn)
            buffer.SetData(values);
    }

    void Dispatch()
    {
        shader.SetFloat("deltaTime", Time.deltaTime);
        int kid = shader.FindKernel("CSMain");
        shader.SetBuffer(kid, "buffer", buffer);
        shader.Dispatch(kid, 2, 2, 1);
    }

    void ReleaseBuffer()
    {
        buffer.Release();
    }
    private void OnDisable()
    {
        ReleaseBuffer();
    }
}