Shader "Custom Pipeline/Unlit"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
    }
    SubShader
    {

        Pass
        {
            HLSLPROGRAM
            #pragma target 3.5

            #pragma multi_compile_instancing //支持GPUInstancing
            #pragma instancing_options assumeuniformscaling //定义缩放矩阵为均匀缩放 不使用额外的逆矩阵数据
            #pragma  vertex UnlitPassVertex
            #pragma  fragment UnlitPassFragment
            #include "../ShaderLibrary/unlit.hlsl"
            
            ENDHLSL
        }
    }
}
