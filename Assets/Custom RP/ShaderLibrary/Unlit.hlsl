#ifndef MYRP_UNLIT_INCLUDE
#define MYRP_UNLIT_INCLUDE


#include"Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
CBUFFER_START(UnityPerFrame)

float4x4 unity_ObjectToWorld;

CBUFFER_END

CBUFFER_START(UnityPerDraw)

float4x4 unity_MatrixVP;

CBUFFER_END


// CBUFFER_START(UnityPerMaterial)
//     float4 _Color;
// CBUFFER_END




#define UNITY_MATRIX_M  unity_ObjectToWorld

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

//使用宏 只有Instancing开启才会定义
UNITY_INSTANCING_BUFFER_START(PerInstance)
    UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_INSTANCING_BUFFER_END(PerInstance)

struct VertexInput
{
    float4 pos : POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID //表示当前正在被渲染的实例索引
};

struct VertexOutput
{
    float4 clipPos : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};


VertexOutput UnlitPassVertex(VertexInput input)
{
    VertexOutput output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input,output); //传递索引
    float4 worldPos = mul(UNITY_MATRIX_M, float4(input.pos.xyz, 1));
    output.clipPos = mul(unity_MatrixVP, worldPos);

    return output;
}

half4 UnlitPassFragment(VertexOutput output) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(output);
    return UNITY_ACCESS_INSTANCED_PROP(PerInstance, _Color);
}
#endif
