///////////////////////////
///                     ///
///     Refraction      ///
///                     ///
///////////////////////////
float3 GetRefractionColor(float2 distortUV, Texture2D CameraDepthTex, sampler sampler_CameraDepthTex, float positionVSz, Texture2D CameraOpaqueTex, sampler sampler_CameraOpaqueTex, float2 screenPosXY)
{
    // ���²���ԭʼ���ͼ������ˮ�����ֵ���Ŷ���Ľ��
    float depthDistortTexture = SAMPLE_TEXTURE2D(CameraDepthTex, sampler_CameraDepthTex, distortUV).x;
    float depthDistortScene = LinearEyeDepth(depthDistortTexture, _ZBufferParams);
    // ˮ��Ť��������ֵ����Ч�������룬���ñ�Ť���ĵط�Ҳ��Ť���ˣ�
    float depthDistortWater = depthDistortScene + positionVSz;
    // �޸�������ͨ���Ƚ����ֵ�� 0 �Ĺ�ϵ���жϸñ�Ť��������
    // ��С�� 0 ʱ��ʹ��δ��Ť�������ֵ�������ڵ��� 0 ʱʹ�ñ�Ť�������ֵ
    // if (depthDistortWater < 0)depthDistortWater = depthWater;
    float2 distortOpaqueUV = distortUV;
    if (depthDistortWater < 0)
        distortOpaqueUV = screenPosXY;

    return SAMPLE_TEXTURE2D(CameraOpaqueTex, sampler_CameraOpaqueTex, distortOpaqueUV).xyz;
}