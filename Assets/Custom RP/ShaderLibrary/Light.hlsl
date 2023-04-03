#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED
#include"./Surface.hlsl"
#include"BRDF.hlsl"
#include"Shadows.hlsl"
#define MAX_DIRECTIONAL_LIGHT_COUNT 4

CBUFFER_START(_CustomLight)
    int _DirectionalLightCount;
    float4 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];
    float4 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];
    float4 _DirectionalLightShadowData[MAX_DIRECTIONAL_LIGHT_COUNT];
CBUFFER_END


struct Light
{
    float3 color;
    float3 direction;
    float attenuation;
};


float SpecularStrength (Surface surface, BRDF brdf, Light light) {
    float3 h = SafeNormalize(surface.viewDirection + light.direction);
    float r2 =  Square(brdf.roughness);
    float d = Square( saturate(dot(surface.normal,h)) )*(r2-1)+1.0001;
    float d2 = Square(d);
    float m = max(0.1,Square(dot(light.direction,h)));
    float n = 4*brdf.roughness+2;

    return r2/(d2*m*n);
}

float3 DirectBRDF(Surface surface,BRDF brdf,Light light)
{
    return SpecularStrength(surface,brdf,light) * brdf.specular + brdf.diffuse;
}

//阴影
DirectionalShadowData GetDirectionalShadowData (int lightIndex) {
    DirectionalShadowData data;
    data.strength = _DirectionalLightShadowData[lightIndex].x;
    data.tileIndex = _DirectionalLightShadowData[lightIndex].y;
    return data;
}

int GetDirectionalLightCount () {
    return _DirectionalLightCount;
}



Light GetDirectionLight(int index,Surface surface)
{
    Light light;
    light.color =_DirectionalLightColors[index].rgb;
    light.direction = _DirectionalLightDirections[index].xyz;
    DirectionalShadowData shadowData = GetDirectionalShadowData(index);
    light.attenuation =  GetDirectionalShadowAttenuation(shadowData,surface);
    return light;
}

float3 IncomingLight(Surface surface,Light light)
{
    return saturate(dot(surface.normal,light.direction)* light.attenuation)*light.color ;
}


float3 GetLighting (Surface surface,Light light , BRDF brdf) {
  //  return SpecularStrength(surface,brdf,light);
   // return light.attenuation;
    return IncomingLight(surface,light) * DirectBRDF(surface,brdf,light);
}

float3 GetLighting (Surface surface,BRDF brdf)
{
    float3 color = 0.0;
    for (int i =0;i<GetDirectionalLightCount();i++)
    {
        color +=   GetLighting(surface,GetDirectionLight(i,surface),brdf);
    }
    return color;
}



#endif