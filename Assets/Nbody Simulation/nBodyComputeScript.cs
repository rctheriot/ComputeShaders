using UnityEngine;
using System.Collections;

public class nBodyComputeScript : MonoBehaviour
{

    public ComputeShader computeShader;
    [Range(0.0f,10.0f)]
    public float timeSpeed;

    public const int vertCount = 5 * 4 * 4 * 4 * 4 * 4;

    private ComputeBuffer positionBuffer;
    private ComputeBuffer massBuffer;
    private ComputeBuffer timeBuffer;
    private ComputeBuffer velocityBuffer;

    private Vector3[] postionData;

    public Shader PointShader;
    Material PointMaterial;

    int CSKernel;


    void Start()
    {
        postionData = new Vector3[vertCount];
        CSKernel = computeShader.FindKernel("CSMain");

        PointMaterial = new Material(PointShader);
        PointMaterial.SetVector("_worldPos", Vector3.zero);

        IntializeBuffers();
    }


    Vector3 RandomDonut(Vector3 center, float dist, float height, float angle)
    {
        Vector3 pos;
        pos.x = center.x + dist * Mathf.Sin(angle * Mathf.Deg2Rad);
        pos.y = center.y + height;
        pos.z = center.z + dist * Mathf.Cos(angle * Mathf.Deg2Rad);
        return pos;
    }

    void IntializeBuffers()
    {
        //Position of Particles
        Vector3[] positions = new Vector3[vertCount];
        Vector3 offset1 = new Vector3(5, 0, 0);
        for (int i = 0; i < vertCount; i++)
        {
            
                float angle = Random.Range(0f, 360f);
                float dist = Random.Range(200f, 400f);
                float height = Random.Range(-15f, 10f);

               positions[i] = RandomDonut(transform.position, dist, height, angle);
            

        }
        positionBuffer = new ComputeBuffer(vertCount, sizeof(float) * 3);
        positionBuffer.SetData(positions);
        PointMaterial.SetBuffer("buf_Points", positionBuffer);


        //Mass Of Particles
        float[] mass = new float[vertCount];
        for (int i = 0; i < vertCount; i++)
        {
            mass[i] = Random.Range(10000, 10000);
        }
        massBuffer = new ComputeBuffer(vertCount, sizeof(float));
        massBuffer.SetData(mass);
        PointMaterial.SetBuffer("buf_Mass", massBuffer);
        computeShader.SetBuffer(CSKernel, "massBuffer", massBuffer);

        //Velocity Buffer
        Vector3[] vel = new Vector3[vertCount];
        for (int i = 0; i < vertCount; i++)
        {
            vel[i] = new Vector3(0, 0, 0);
        }
        velocityBuffer = new ComputeBuffer(vertCount, sizeof(float) * 3);
        velocityBuffer.SetData(vel);
        computeShader.SetBuffer(CSKernel, "velocityBuffer", velocityBuffer);

        //Time
        timeBuffer = new ComputeBuffer(vertCount, sizeof(float));
        computeShader.SetBuffer(CSKernel, "timeBuffer", timeBuffer);

    }

    public void Dispatch()
    {
        timeBuffer.SetData(new[] { Time.deltaTime * timeSpeed });
        computeShader.SetBuffer(CSKernel, "positionBuffer", positionBuffer);
        computeShader.SetBuffer(CSKernel, "timeBuffer", timeBuffer);
        computeShader.Dispatch(CSKernel, 10, 10, 10);
    }

    void ReleaseBuffers()
    {
        positionBuffer.Release();
        timeBuffer.Release();
        massBuffer.Release();
        velocityBuffer.Release();
        DestroyImmediate(PointMaterial);
    }

    void OnRenderObject()
    {
        Dispatch();
        PointMaterial.SetPass(0);
        positionBuffer.GetData(postionData);
        Vector3 zeroPos = new Vector3(0, 0, 0);
        for (int i = 0; i < vertCount; i++)
        {
            zeroPos.x += postionData[i].x;
            zeroPos.y += postionData[i].y;
            zeroPos.z += postionData[i].z;
        }
        zeroPos.x /= vertCount;
        zeroPos.y /= vertCount;
        zeroPos.z /= vertCount;

        PointMaterial.SetVector("_centerPos", zeroPos);
        Graphics.DrawProcedural(MeshTopology.Points, vertCount);
    }

    private void OnDisable()
    {
        ReleaseBuffers();
    }
}
