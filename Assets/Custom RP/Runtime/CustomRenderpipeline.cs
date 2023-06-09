﻿/*************************
文件:CustomRenderpipeline.cs
作者:cocoa
创建时间:2023-03-20 23-07-50
描述：
************************/

using UnityEngine;
using UnityEngine.Rendering;

public class CustomRenderpipeline: RenderPipeline
{
    private CameraRender renderer;
    private bool dynamicBatching, instancing;
    public CustomRenderpipeline(bool dynamicBatching,bool instancing,bool useSRPBatcher)
    {
        this.dynamicBatching = dynamicBatching;
        this.instancing = instancing;
        GraphicsSettings.useScriptableRenderPipelineBatching = useSRPBatcher;
        GraphicsSettings.lightsUseLinearIntensity = true;
        renderer = new CameraRender();
    }
    protected override void Render(ScriptableRenderContext context, Camera[] cameras)
    {
        foreach (Camera camera in cameras)
        {
            renderer.Render(context,camera,dynamicBatching,instancing);
        }
    }
}
