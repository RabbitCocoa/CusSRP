/*************************
文件:Lighting.cs
作者:cocoa
创建时间:2023-03-24 00-39-03
描述：
************************/

using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;

public class Lighting
{
    private const string bufferName = "Lighting";

    //GPU CBUFFER 数据 写在Shader里
    static int
        dirLightCountId = Shader.PropertyToID("_DirectionalLightCount"),
        dirLightColorId = Shader.PropertyToID("_DirectionalLightColors"),
        dirLightDirectionId = Shader.PropertyToID("_DirectionalLightDirections"),
          dirLightShadowDataId = Shader.PropertyToID("_DirectionalLightShadowData");

    //传递给GPU的数据
    private static Vector4[]
        dirLightColors = new Vector4[maxDirLightCount],
        dirLightDirections = new Vector4[maxDirLightCount],
         dirLightShadowData = new Vector4[maxDirLightCount];
    
    private CommandBuffer buffer = new CommandBuffer()
    {
        name = bufferName
    };

    private CullingResults CullingResults;

    private const int maxDirLightCount = 4;

    private Shadow shadow = new Shadow();
    public void SetUp(ScriptableRenderContext context,CullingResults results,ShadowSettings shadowSettings)
    {
        this.CullingResults = results;
        
        
        buffer.BeginSample(bufferName);
        shadow.SetUp(context, results, shadowSettings);
        SetUpLights();
        shadow.Render();
        
    //    SetupDirectionLight();
        buffer.EndSample(bufferName);
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }
    
    public void CleanUp()
    {
        shadow.CleanUp();
    }

    //设置灯光数量 裁剪
    void SetUpLights()
    {
        //共享内存 方便Unity与C#代码共享数据
        NativeArray<VisibleLight> visibleLights = this.CullingResults.visibleLights;
        int dirLightCount = 0;
        for (int i = 0; i < visibleLights.Length; i++)
        {
            
            VisibleLight visibleLight = visibleLights[i];
            if (visibleLight.lightType == LightType.Directional)
            {
                SetupDirectionLight(dirLightCount++,ref visibleLight);
                if (dirLightCount >= maxDirLightCount)
                    break;
            }
        }
        buffer.SetGlobalInt(dirLightCountId,visibleLights.Length);
        buffer.SetGlobalVectorArray(dirLightColorId,dirLightColors);
        buffer.SetGlobalVectorArray(dirLightDirectionId,dirLightDirections);
        buffer.SetGlobalVectorArray(dirLightShadowDataId,dirLightShadowData);
    }

    //设置直接光数据给GPU
    void SetupDirectionLight(int index,ref VisibleLight visibleLight)
    {
        dirLightShadowData[index] = shadow.ReserveDirectionalShadows(visibleLight.light,index);

        
        dirLightColors[index] = visibleLight.finalColor;
        //取第二列 即y轴方向
        dirLightDirections[index] = -visibleLight.localToWorldMatrix.GetColumn(2);
        
        // Light light = RenderSettings.sun;
        // buffer.SetGlobalVector(dirLightColorId, light.color.linear * light.intensity);
        // buffer.SetGlobalVector(dirLightDirectionId, -light.transform.forward);
    }
    
    
}
