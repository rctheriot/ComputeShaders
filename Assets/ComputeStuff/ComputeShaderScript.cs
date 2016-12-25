using UnityEngine;
using System.Collections;

public class ComputeShaderScript : MonoBehaviour
{

    public ComputeShader computeShader;

    public const int vertCount = 5 * 5 * 5 * 5 * 5 * 5;

    private ComputeBuffer positionBuffer;
    private ComputeBuffer timeBuffer;
    private ComputeBuffer selectionBuffer;

    public Shader PointShader;
    Material PointMaterial;
    private int selectionNum = 1;

    int CSKernel;

    public float size = 1;

    private float speed = 0.15f;

    Vector3[] startPositions;


    void Start()
    {
   
        CSKernel = computeShader.FindKernel("CSMain");
        PointMaterial = new Material(PointShader);
        PointMaterial.SetVector("_worldPos", transform.position);
        IntializeBuffers();
    }

    void Update()
    {
        if (CC_INPUT.GetButtonDown(Wand.Left, WandButton.Right))
        {
            selectionNum++;
            if (selectionNum > 1) selectionNum = 0;

        }

        if (CC_INPUT.GetButtonDown(Wand.Left, WandButton.Left))
        {
            positionBuffer.SetData(startPositions);
            PointMaterial.SetBuffer("buf_Points", positionBuffer);

        }

        speed -= (CC_INPUT.GetAxis(Wand.Left, WandAxis.Trigger) * Time.deltaTime); 
        speed += (CC_INPUT.GetAxis(Wand.Right, WandAxis.Trigger) * Time.deltaTime);

        if (speed <= 0) speed = 0.01f;
        if (speed >= 1) speed = 1.0f;
    }

    void IntializeBuffers()
    {
        startPositions = new Vector3[vertCount];
        for (int i = 0; i < vertCount; i++)
        {
            startPositions[i] = Random.insideUnitSphere;
        }
        positionBuffer = new ComputeBuffer(vertCount, sizeof(float) * 3);
        positionBuffer.SetData(startPositions);
        PointMaterial.SetBuffer("buf_Points", positionBuffer);

        timeBuffer = new ComputeBuffer(1, sizeof(float));
        selectionBuffer = new ComputeBuffer(1, sizeof(int));

    }

    public void Dispatch()
    {
        timeBuffer.SetData(new[] { Time.deltaTime * speed });
        selectionBuffer.SetData(new[] { selectionNum });
        computeShader.SetBuffer(CSKernel, "timeBuffer", timeBuffer);
        computeShader.SetBuffer(CSKernel, "selectionBuffer", selectionBuffer);
        computeShader.SetBuffer(CSKernel, "positionBuffer", positionBuffer);
        computeShader.Dispatch(CSKernel, 10, 10, 10);
    }

    void ReleaseBuffers()
    {
        timeBuffer.Release();
        selectionBuffer.Release();
        positionBuffer.Release();
        DestroyImmediate(PointMaterial);
    }

    void OnRenderObject()
    {
        Dispatch();
        PointMaterial.SetFloat("_Size", size);
    
        PointMaterial.SetPass(0);
        Graphics.DrawProcedural(MeshTopology.Points, vertCount);

    }


    private void OnDisable()
    {
        ReleaseBuffers();
    }
}
