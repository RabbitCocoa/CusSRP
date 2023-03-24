#ifndef CUSTOM_BRDF_INCLUDE
#define CUSTOM_BRDF_INCLUDE

#include"Common.hlsl"
#include"Surface.hlsl"

struct BRDF
{
    float3 diffuse;
    float3 specular;
    float roughness;
};

#define MIN_REFLECTIVITY 0.04

float OneMinusReflectivity(float metallic)
{
    float range = 1.0 - MIN_REFLECTIVITY;
    return range - metallic * range;
}



BRDF GetBRDF(Surface surface,bool applyAlphaToDiffuse = false)
{
    BRDF brdf;
    float oneMinusReflectivity = OneMinusReflectivity(surface.metallic);
    brdf.diffuse = surface.color * oneMinusReflectivity;
    if(applyAlphaToDiffuse)
     brdf.diffuse *= surface.alpha;
    
    brdf.specular = lerp(MIN_REFLECTIVITY, surface.color, surface.metallic);; //surface.color - brdf.diffuse;
    float perceptualRoughness = PerceptualSmoothnessToRoughness(surface.Smoothness);
    brdf.roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
    return brdf;
}

#endif
