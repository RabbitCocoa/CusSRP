/*************************
文件:MeshBall.cs
作者:cocoa
创建时间:2023-03-24 11-17-16
描述：
************************/

using System;
using UnityEngine;
using Random = UnityEngine.Random;

public class MeshBall : MonoBehaviour
{
    static int colorID = Shader.PropertyToID("_Color");

    [SerializeField] private Mesh mesh = default;
    [SerializeField] private Material _material = default;


    private Matrix4x4[] matrics = new Matrix4x4[1023];
    private Vector4[] _Colors = new Vector4[1023];

    private MaterialPropertyBlock _materialPropertyBlock;

    private void Awake()
    {
        for (int i = 0; i < matrics.Length; i++)
        {
            matrics[i] = Matrix4x4.TRS(
                Random.insideUnitSphere * 10f, Quaternion.identity, Vector3.one
            );
            _Colors[i] = new Vector4(Random.value, Random.value, Random.value, 1f);
        }
    }
    void Update () {
        if (_materialPropertyBlock == null) {
            _materialPropertyBlock = new MaterialPropertyBlock();
            _materialPropertyBlock.SetVectorArray(colorID, _Colors);
        }
        Graphics.DrawMeshInstanced(mesh, 0, _material, matrics, 1023, _materialPropertyBlock);
    }
}
