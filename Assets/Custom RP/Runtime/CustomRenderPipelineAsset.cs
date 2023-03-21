using System.Collections;
using System.Collections.Generic;
using Sirenix.OdinInspector;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")]
public class CustomRenderPipelineAsset : RenderPipelineAsset
{
    private bool enableBatching;

    [ShowInInspector]
    private bool EnableBathcing
    {
        get => enableBatching;
        set
        {
            enableBatching = value;
            if(value)
            enableInstancing = !value;
        }
    }

    private bool enableInstancing;

    [ShowInInspector]
    private bool EnableInstancing
    {
        get => enableInstancing;
        set
        {
            enableInstancing = value;
            if(value)
            enableBatching = !value;
        }
    }

    protected override RenderPipeline CreatePipeline()
    {
        return new CustomRenderpipeline(EnableBathcing, EnableInstancing);
    }
}