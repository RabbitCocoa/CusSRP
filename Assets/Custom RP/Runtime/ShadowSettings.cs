/*************************
文件:ShadowSettings.cs
作者:cocoa
创建时间:2023-03-29 20-06-00
描述：
************************/

using System;
using Sirenix.OdinInspector;

[Serializable]
public class ShadowSettings
{
    private int[] TextureSizes = { 256, 512, 1024, 2048, 4096, 8192 };
    [MinValue(0)]
    public float maxDistance = 100f;
    
    [ValueDropdown("TextureSizes")]
    public int atlasSize = 256;
}
