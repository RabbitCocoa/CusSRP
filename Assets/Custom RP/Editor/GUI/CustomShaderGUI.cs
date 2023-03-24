/*************************
文件:CustomShaderGUI.cs
作者:cocoa
创建时间:2023-03-24 15-40-07
描述：
************************/

using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class CustomShaderGUI : ShaderGUI
{
    private bool showPresets;
    private MaterialEditor editor;
    //选中的物体
    private Object[] materials;
    private MaterialProperty[] Properties;

    #region 预设属性
    bool Clipping {
        set => SetProperty("_Clipping", "_CLIPPING", value);
    }

    bool HasPremultiplyAlpha => HasProperty("_PremulAlpha");
    
    bool PremultiplyAlpha {
        set => SetProperty("_PremulAlpha", "_PREMULTIPLY_ALPHA", value);
    }

    BlendMode SrcBlend {
        set => SetProperty("_SrcBlend", (float)value);
    }

    BlendMode DstBlend {
        set => SetProperty("_DstBlend", (float)value);
    }

    bool ZWrite {
        set => SetProperty("_ZWrite", value ? 1f : 0f);
    }

    RenderQueue RenderQueue
    {
        set
        {
            foreach (Material m in materials)
            {
                m.renderQueue = (int)value;
            }
        }
    }

    #endregion
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        base.OnGUI(materialEditor, properties);
        editor = materialEditor;
        Properties = properties;
        materials = materialEditor.targets;

        EditorGUILayout.Space();
        showPresets = EditorGUILayout.Foldout(showPresets, "Pressets", true);

        if (showPresets)
        {
            OpaquePreset();
            ClipingPreset();
            FadePreset();
            TransparentPreset();
        }
    }

    bool HasProperty (string name) =>
        FindProperty(name, Properties, false) != null;
    bool SetProperty(string name, float value)
    {
        var property = FindProperty(name, Properties,false);
        if (property == null)
            return false;
        property.floatValue = value;
        return true;
    }

    //用于toggle变量
    void SetProperty(string name, string keyworld, bool value)
    {
        SetProperty(name,value?1f:0f);
        SetKeyWord(keyworld,value);
    }
    void SetKeyWord(string keyworld, bool enabled)
    {
        if (enabled)
        {
            foreach (Material material in materials)
            {
                material.EnableKeyword(keyworld);
            }
        }
        else
        {
            foreach (Material material in materials)
            {
                material.DisableKeyword(keyworld);
            }
        }
    }

    bool PresetButton(string name)
    {
        if (GUILayout.Button(name))
        {
            editor.RegisterPropertyChangeUndo(name);
            return true;
        }

        return false;
    }

    void OpaquePreset()
    {
        if (PresetButton("Opaque"))
        {
            Clipping = false;
            PremultiplyAlpha = false;
            SrcBlend = BlendMode.One;
            DstBlend = BlendMode.Zero;
            ZWrite = true;
            RenderQueue = RenderQueue.Geometry;
        }
    }
    
    void ClipingPreset()
    {
        if (PresetButton("Cliping"))
        {
            Clipping = true;
            PremultiplyAlpha = false;
            SrcBlend = BlendMode.One;
            DstBlend = BlendMode.Zero;
            ZWrite = true;
            RenderQueue = RenderQueue.AlphaTest;
        }
    }
    
    void FadePreset()
    {
        if (PresetButton("Fade"))
        {
            Clipping = false;
            PremultiplyAlpha = false;
            SrcBlend = BlendMode.SrcAlpha;
            DstBlend = BlendMode.OneMinusSrcAlpha;
            ZWrite = false;
            RenderQueue = RenderQueue.Transparent;
        }
    }
    
    void TransparentPreset()
    {
        if (HasPremultiplyAlpha && PresetButton("Transparent"))
        {
            Clipping = false;
            PremultiplyAlpha = true;
            SrcBlend = BlendMode.One;
            DstBlend = BlendMode.OneMinusSrcAlpha;
            ZWrite = false;
            RenderQueue = RenderQueue.Transparent;
        }
    }
    
}
