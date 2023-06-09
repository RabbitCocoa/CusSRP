Shader "Custom Pipeline/Unlit"
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
    }
    SubShader
    {

        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            ZWrite[_ZWrite]
            
            HLSLPROGRAM
            #pragma target 3.5
            #pragma shader_feature _CLIPPING
            #pragma multi_compile_instancing //支持GPUInstancing
            #pragma instancing_options assumeuniformscaling //定义缩放矩阵为均匀缩放 不使用额外的逆矩阵数据
            #pragma  vertex UnlitPassVertex
            #pragma  fragment UnlitPassFragment
            #include "../ShaderLibrary/unlit.hlsl"
            
            ENDHLSL
        }
    }
     CustomEditor "CustomShaderGUI"
}
