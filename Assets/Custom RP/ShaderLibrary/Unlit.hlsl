#ifndef MYRP_UNLIT_INCLUDE
#define MYRP_UNLIT_INCLUDE


#include"Common.hlsl"




// CBUFFER_START(UnityPerMaterial)
//     float4 _Color;
// CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    //	float4 _BaseColor;
UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)


struct VertexInput
{
    float4 pos : POSITION;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID //表示当前正在被渲染的实例索引
};

struct VertexOutput
{
    float4 clipPos : SV_POSITION;
    float2 uv : VAR_BASE_UV;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};


VertexOutput UnlitPassVertex(VertexInput input)
{
    VertexOutput output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input,output); //传递索引
    float4 worldPos = mul(UNITY_MATRIX_M, float4(input.pos.xyz, 1));
    output.clipPos = mul(unity_MatrixVP, worldPos);

    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BaseMap_ST);
    output.uv =   input.uv * baseST.xy + baseST.zw ;//SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv);
    
    return output;
}

half4 UnlitPassFragment(VertexOutput output) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(output);
    
    float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,output.uv);
    float4 color =  UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color) * baseMap;
    #if defined(_CLIPPING)
    clip(color.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff));

    #endif
    
    return color;
}
#endif
