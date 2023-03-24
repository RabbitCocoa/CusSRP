/*************************
文件:InstancedColor.cs
作者:cocoa
创建时间:2023-03-21 23-33-45
描述：让颜色参与实例化
************************/

using System;
using Sirenix.OdinInspector;
using UnityEngine;

public class InstancedColor : MonoBehaviour
{
    [SerializeField] private Color color = Color.white;
    [SerializeField, Range(0, 1)] private float cutOff;
    [SerializeField, Range(0, 1)] private float metallic;
    [SerializeField, Range(0, 1)] private float smoothness;
    static int colorID = Shader.PropertyToID("_Color");
    static int cutoffId = Shader.PropertyToID("_Cutoff");
    static int MetallicID = Shader.PropertyToID("_Metallic");
    static int SmoothnessId = Shader.PropertyToID("_Smoothness");
    
    private static MaterialPropertyBlock propertyBlock;
    
    private void Awake()
    {
        OnValidate();
    }

    private void OnValidate()
    {
        if (propertyBlock == null)
        {
            propertyBlock = new MaterialPropertyBlock();
        }
        propertyBlock.SetColor(colorID,color);
        propertyBlock.SetFloat(cutoffId,cutOff);
        propertyBlock.SetFloat(MetallicID,metallic);
        propertyBlock.SetFloat(SmoothnessId,smoothness);
        GetComponent<MeshRenderer>().SetPropertyBlock(propertyBlock);
    }
}
