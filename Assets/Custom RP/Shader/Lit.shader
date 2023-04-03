Shader "Custom Pipeline/Lit"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _BaseMap("Main Texture",2D) = "white"{}
           _Cutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend ("Src Blend", Float) = 1
		[Enum(UnityEngine.Rendering.BlendMode)]_DstBlend ("Dst Blend", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite ("Z Write", Float) = 1
        [Toggle(_CLIPPING)] _Clipping ("Alpha Clipping", Float) = 0
        [Toggle(_PREMULTIPLY_ALPHA)] _PremulAlpha ("Premultiply Alpha", Float) = 0
        _Metallic ("Metallic", Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5
    }
    SubShader
    {
        
        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            Tags{
                "LightMode" = "CustomLit"
            }
            HLSLPROGRAM
            #pragma target 3.5
            #pragma shader_feature _CLIPPING
            #pragma shader_feature _PREMULTIPLY_ALPHA
            #pragma multi_compile_instancing //支持GPUInstancing
            #pragma instancing_options assumeuniformscaling //定义缩放矩阵为均匀缩放 不使用额外的逆矩阵数据
            #pragma  vertex litPassVertex
            #pragma  fragment litPassFragment
            #include "../ShaderLibrary/Lit.hlsl"
            
            ENDHLSL
        }
        
        Pass{
            Tags{
                "LightMode" = "ShadowCaster"   
            }    
            ColorMask 0
            HLSLPROGRAM
            #pragma  target3.5
            #pragma shader_feature _CLIPPING
            #pragma multi_compile_instancing //支持GPUInstancing
            #pragma  vertex ShadowPassVertex
            #pragma  fragment ShadowPassFragment
            #include "../ShaderLibrary/ShadowCaster.hlsl"
            ENDHLSL
        }
    }
    
    CustomEditor "CustomShaderGUI"
}
