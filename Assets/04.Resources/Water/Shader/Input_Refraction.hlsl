///////////////////////////
///                     ///
///     Refraction      ///
///                     ///
///////////////////////////
float3 GetRefractionColor(float2 distortUV, Texture2D CameraDepthTex, sampler sampler_CameraDepthTex, float positionVSz, Texture2D CameraOpaqueTex, sampler sampler_CameraOpaqueTex, float2 screenPosXY)
{
    // 重新采样原始深度图并计算水的深度值被扰动后的结果
    float depthDistortTexture = SAMPLE_TEXTURE2D(CameraDepthTex, sampler_CameraDepthTex, distortUV).x;
    float depthDistortScene = LinearEyeDepth(depthDistortTexture, _ZBufferParams);
    // 水被扭曲后的深度值（但效果不理想，不该被扭曲的地方也被扭曲了）
    float depthDistortWater = depthDistortScene + positionVSz;
    // 修复方法：通过比较深度值与 0 的关系来判断该被扭曲的区域
    // 当小于 0 时，使用未被扭曲的深度值，但大于等于 0 时使用被扭曲的深度值
    // if (depthDistortWater < 0)depthDistortWater = depthWater;
    float2 distortOpaqueUV = distortUV;
    if (depthDistortWater < 0)
        distortOpaqueUV = screenPosXY;

    return SAMPLE_TEXTURE2D(CameraOpaqueTex, sampler_CameraOpaqueTex, distortOpaqueUV).xyz;
}