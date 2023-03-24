#ifndef MYRP_LIT_INCLUDE
#define MYRP_LIT_INCLUDE

#include"Common.hlsl"
#include"Surface.hlsl"
#include"Light.hlsl"



//使用宏 只有Instancing开启才会定义

//SRP Bathcing 
// CBUFFER_START(UnityPerMaterial)
// float4 _Color;
// CBUFFER_END

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);


UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float4, _BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)
    UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
    UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)
    UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)




struct VertexInput
{
    float4 pos : POSITION;
    float3 normalOs : NORMAL;
    float2 uv : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID //表示当前正在被渲染的实例索引
};

struct VertexOutput
{
    float4 clipPos : SV_POSITION;
    float3 positionWS : VAR_POSITION;
    float3 normalWs : VAR_NORMAL;
    float2 uv : VAR_BASE_UV;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};


VertexOutput litPassVertex(VertexInput input)
{
    VertexOutput output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input,output); //传递索引
    float3 worldPos = TransformObjectToWorld(input.pos);
    output.positionWS = worldPos;
    output.clipPos = TransformObjectToHClip( input.pos);
    output.normalWs = TransformObjectToWorldNormal(input.normalOs);

    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_BaseMap_ST);
    output.uv =   input.uv * baseST.xy + baseST.zw ;//SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,input.uv);
    return output;
}

half4 litPassFragment(VertexOutput output) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(output);
    Surface surface;
    surface.viewDirection = normalize(_WorldSpaceCameraPos - output.positionWS);
    surface.normal = normalize(output.normalWs);
     float4 color =  UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color) ;//;* float4(normalize(output.normalWs),1);
    surface.color = color.rgb;
    surface.alpha = color.a;
    surface.metallic = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Metallic);
    surface.Smoothness = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial,_Smoothness);


    #if defined(_PREMULTIPLY_ALPHA)
    BRDF brdf = GetBRDF(surface, true);
    #else
    BRDF brdf = GetBRDF(surface);
    #endif
    
    float3 c =  GetLighting(surface,brdf);
    float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,output.uv);

    float4 res = float4(c,surface.alpha) * baseMap;
    #if defined(_CLIPPING)
     clip(res.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Cutoff));
    #endif
    
    return res;
    // return abs(length( normalize(output.normalWs))-1.0f)*10.0f;
    //return half4( UNITY_ACCESS_INSTANCED_PROP(PerInstance, _Color) * normalize( output.normalWs),1);
}
#endif
