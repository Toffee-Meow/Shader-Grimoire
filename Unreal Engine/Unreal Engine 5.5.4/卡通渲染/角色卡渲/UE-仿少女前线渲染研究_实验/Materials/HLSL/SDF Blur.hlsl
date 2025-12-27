//SDF面部阴影抗锯齿
//HLSL代码放入材质蓝图Custom节点里使用
//添加输入索引端口：TexObject、TexCoord、Dit、BlurIntensity

float shadow = 0;

float texelsize = 1./BlurIntensity*Dit;

for (int x = -1;x<= 1; ++x)

{

    for(int y = -1;y <= 1; ++y)

    {

        float TexR = Texture2DSample(TexObject,

TexObjectSampler,TexCoord + float2(x,y)*texelsize).r;

        shadow += TexR;

    }

}

shadow /= 9.;

return shadow;