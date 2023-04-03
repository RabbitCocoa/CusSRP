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
            if (value)
            {
                enableInstancing = false;
                enableSRPBatch = false;
            }
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
            if (value)
            {
                enableBatching = false;
                enableSRPBatch = false;
            }
        }
    }

    private bool enableSRPBatch;
    [ShowInInspector]
    private bool EnableSRPBatch
    {
        get => enableSRPBatch;
        set
        {
            enableSRPBatch = value;
            if (value)
            {
                enableBatching = false;
                enableInstancing = false;
            }
        }
    }
    
    [SerializeField]
    private ShadowSettings ShadowSettings;
    
    protected override RenderPipeline CreatePipeline()
    {
        return new CustomRenderpipeline(EnableBathcing, EnableInstancing,EnableSRPBatch,ShadowSettings);
    }
}