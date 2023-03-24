/*************************
文件:CameraRender.cs
作者:cocoa
创建时间:2023-03-20 23-13-28
描述：
************************/

using UnityEngine;
using UnityEngine.Rendering;

public partial class CameraRender
{
    private Lighting lighting = new Lighting();
    public CameraRender()
    {
      
    }


    
    private ScriptableRenderContext context;
    private Camera camera;

    private const string bufferName = "Render Camera";
    static ShaderTagId[] visiableShaderTagIdS =
    {
        new ShaderTagId("SRPDefaultUnlit"),
        new ShaderTagId("CustomLit")
        
    };
    

    
    private CullingResults cullingResults;
    private CommandBuffer buffer = new CommandBuffer()
    {
        name = bufferName
    };

    private bool dynamicBatching, instancing;
    public void Render(ScriptableRenderContext context, Camera camera,bool dynamicBatching,bool instancing)
    {
        this.context = context;
        this.camera = camera;
        this.dynamicBatching = dynamicBatching;
        this.instancing = instancing;
        
        PrepareBuffer();
        //把UI扔进scene窗口的世界中
        PrepareForSceneWindow();
        //裁剪
        if (!Cull())
            return;
        //设置相机属性 
        Setup();
        
        //设置光线数据
        lighting.SetUp(context,cullingResults);
        
        //绘制物体
        DrawVisibleGeometry();
      
        //绘制不支持的shader
        DrawUnsupportedShaders();
        DrawGizmos();
        //提交指令
        Submit();
    }

    void Setup()
    {
        //设置相机属性 VP矩阵
        //如果该方法放在清理之后,清理操作会试用Draw GL 画一个矩形
        //如果该方法在清理之前,只会进行单纯的Clear(Color+z+stencil)操作 速度更快
        context.SetupCameraProperties(camera);
        CameraClearFlags flags = camera.clearFlags;
        //清理深度 颜色 背景颜色为空
        buffer.ClearRenderTarget(flags <= CameraClearFlags.Depth,flags <= CameraClearFlags.Color,flags == CameraClearFlags.Color ? camera.backgroundColor.linear : Color.clear);
        //在FrameDebug 中开始采样
        buffer.BeginSample(SampleName);
   
        ExecuteBuffer();
     
    }

    
    //裁剪掉看不掉的物体
    bool Cull()
    {
        //获取相机的裁剪参数
        if (camera.TryGetCullingParameters(out ScriptableCullingParameters p))
        {
            //通过裁剪参数获得一个裁剪结果
            cullingResults = context.Cull(ref p);
            return true;
        }
        return false;
    }
    

    void DrawVisibleGeometry()
    {
        var sortingSettings = new SortingSettings(camera)
        {
            criteria = SortingCriteria.CommonOpaque
        };

        var drawSettings = new DrawingSettings(visiableShaderTagIdS[0],sortingSettings); //Shader 和 绘制顺序设置
        drawSettings.enableDynamicBatching = dynamicBatching;
        drawSettings.enableInstancing = instancing;
        for (int i = 1; i < visiableShaderTagIdS.Length; i++)
        {
            drawSettings.SetShaderPassName(i,visiableShaderTagIdS[i]);
        }
        
        var filteringSettings = new FilteringSettings(RenderQueueRange.opaque); //队列设置
       

        //先画不透明物体
        context.DrawRenderers(cullingResults,ref drawSettings,ref filteringSettings);
        
       //在画天空盒 
       context.DrawSkybox(camera);
        //最后画透明物体
        sortingSettings.criteria = SortingCriteria.CommonTransparent;
        drawSettings.sortingSettings = sortingSettings;
        filteringSettings.renderQueueRange = RenderQueueRange.transparent;
        
        context.DrawRenderers(cullingResults,ref drawSettings,ref filteringSettings);
    }


    
    void Submit()
    {
        buffer.EndSample(SampleName);
        ExecuteBuffer();
        context.Submit();
    }

    //提交缓冲命令
    void ExecuteBuffer()
    {
        context.ExecuteCommandBuffer(buffer);
        buffer.Clear();
    }
}
