#ifndef  CUSTOM_SHADOWCASTER_INCLUDED
#define CUSTOM_SHADOWCASTER_INCLUDED
#include"Common.hlsl"
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)
    UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
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

VertexOutput ShadowPassVertex(VertexInput v)
{
    VertexOutput o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v,o); //传递索引

    float3 positionWS = TransformObjectToWorld(  v.pos);
    o.clipPos = TransformWorldToHClip(positionWS);

    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BaseMap_ST);
    o.uv =  v.uv * baseST.xy + baseST.zw;
    return o;
    
}

float4 ShadowPassFragment(VertexOutput o): SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(o);

    float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,o.uv);
    float4 color =  UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color) ;
    float4 base = baseMap * color;
    #if defined(_CLIPPING)
    clip(base.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff));
    #endif
    return base;
}
#endif