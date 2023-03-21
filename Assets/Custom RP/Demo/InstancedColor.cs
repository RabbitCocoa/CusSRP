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
    
    static int colorID = Shader.PropertyToID("_Color");
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
        GetComponent<MeshRenderer>().SetPropertyBlock(propertyBlock);
    }
}
