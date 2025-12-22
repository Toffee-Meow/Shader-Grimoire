// UI渐变透明Shader
// 效果：实现可调节的图像透明度渐变效果，可用于模拟图像倒影
// 使用位置：UI图片
// 原理：利用 图像UV变化 控制 图像透明度Alpha
// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "UI/GradientTransparent"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        
        _GradientPower ("GradientPower", Range(1, 15)) = 1      //添加可调参数_GradientPower，数值范围[1,15]，初值为1，在外显示"GradientPower"
        _OffsetY ("Offset Y", Range(-1, 1)) = 0                 //添加可调参数_OffsetY，数值范围[-1,1]，初值为0，在外显示"Offset Y"
        _MaxAlpha ("Max Alpha", Range(0, 1)) = 1                //添加可调参数_MaxAlpha，数值范围[0,1]，初值为1，在外显示"Max Alpha"

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP


            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                float4  mask : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float _UIMaskSoftnessX;
            float _UIMaskSoftnessY;
            int _UIVertexColorAlwaysGammaSpace;
            float _GradientPower;                                               //声明参数_GradientPower
            float _OffsetY;                                                     //声明参数_OffsetY
            float _MaxAlpha;                                                    //声明参数_MaxAlpha

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                float4 vPosition = UnityObjectToClipPos(v.vertex);
                OUT.worldPosition = v.vertex;
                OUT.vertex = vPosition;

                float2 pixelSize = vPosition.w;
                pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                OUT.mask = float4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));


                if (_UIVertexColorAlwaysGammaSpace)
                {
                    if(!IsGammaSpace())
                    {
                        v.color.rgb = UIGammaToLinear(v.color.rgb);
                    }
                }

                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                //Round up the alpha color coming from the interpolator (to 1.0/256.0 steps)
                //The incoming alpha could have numerical instability, which makes it very sensible to
                //HDR color transparency blend, when it blends with the world's texture.
                const half alphaPrecision = half(0xff);
                const half invAlphaPrecision = half(1.0/alphaPrecision);
                IN.color.a = round(IN.color.a * alphaPrecision)*invAlphaPrecision;

                half4 color = IN.color * (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd);
                
                //使用UV坐标，并添加两可调参数_OffsetY和_GradientPower
                //-IN.texcoord.y反转UV坐标
                //利用数学公式曲线(1-x+b)^a控制图像 透明度变化幅度/强度 和 透明度变化起始位置/偏移位置
                //由a=_GradientPower调节 透明度变化幅度/强度，_GradientPower越大变化幅度/强度越大
                //由b=_OffsetY调节 透明度变化起始位置/偏移位置，_OffsetY越大，起始位置越沿Y轴向下偏移
                //使用saturate()函数限定计算结果不超过1，防止与图像Alpha相乘后，产生图像过曝
                float y = pow(1 - saturate(IN.texcoord.y + _OffsetY), _GradientPower);
                //添加_MaxAlpha可调参数，控制整体图像整体透明度Alpha
                //利用线性插值lerp(min,max,t)函数，在两个已知的值(min,max)之间按比例计算中间值，计算公式min+(max-min)*t，t取值[0，1]
                //min=0，max=_MaxAlpha范围[0,1]，t=y，_MaxAlpha值越小，图像整体透明度越小
                float alpha = lerp(0, _MaxAlpha, y);
                //输出color*alpha后输出最终颜色，以实现利用 图像UV变化 控制 图像透明度Alpha 的效果
                color *= alpha;

                #ifdef UNITY_UI_CLIP_RECT
                half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
                color.a *= m.x * m.y;
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                color.rgb *= color.a;

                return color;
            }
        ENDCG
        }
    }
}