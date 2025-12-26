//调色板数值可参考cosine gradient generator http://dev.thi.ng/gradients/
//三角函数计算调色板
vec3 palette( float t )                       //设置图形调色板函数，和输入参数，5个变量，12个参数
{
    vec3 a = vec3(0.5, 0.5, 0.5);               //设置调色板DC Offset
    vec3 b = vec3(0.5, 0.5, 0.5);               //设置调色板Amp
    vec3 c = vec3(1.0, 1.0, 1.0);               //设置调色板Freq
    vec3 d = vec3(0.263, 0.416, 0.557);         //设置调色板Phase

    return a + b*cos( 6.28318 * ( c*t+d ) );    //从函数中返回一个值，输入变量t，带入函数中计算
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;   //数学整合结果
    // vec2 uv = fragCoord / iResolution.xy * 2.0 -1.0;             //获取画布坐标
    // uv.x *= iResolution.x / iResolution.y;                       //避免画布改变导致效果扭曲，保持比例
    // uv -= 0.5;
    // uv *= 2.0;
    vec2 uv0 = uv;                                                  //设置迭代uv0
    vec3 finalColor = vec3(0.0, 0.0, 0.0);                          //给输出颜色载体设定初始颜色黑色

    for(float i = 0.0; i < 4.0; i ++)
    {
        // uv *= 2.0;
        // uv = fract(uv);                                          //使用分数函数，实现空间重复
        // uv -= 0.5;                                               //[0,1]，修复裁剪坐标位置[-1,1]，uv*2-0.5
        uv = fract(uv * 1.5) - 0.5;                                 //空间重复并修复裁剪坐标

        float d = length(uv) * exp(-length(uv0));                   //length(uv)计算每个像素点到中心坐标的距离，使用x*exp(-x)图像截取[0,1]之间光滑而独特的曲线，实现光滑效果
        // d -= 0.5;
        vec3 col = palette(length(uv0) + i*0.4 + iTime*0.4);        //输出颜色使用palette()函数，将每个像素点距离屏幕中心的距离作为输入
        //并加入时间常量，达到颜色循环向平面中心流动效果，将i纳入输出颜色循环，导致每次迭代后轻微的颜色偏移

        d = sin(8.0*d + iTime)/8.0;                                 //使用三角函数，实现循环圆环图案效果，/加除法可以增加对比度
        d = abs(d);                                                 //对length()取绝对值，实现中心渐变效果
        // d = smoothstep(0.0, 1.1, d);                             //平滑阶跃函数，实现渐变效果
        d = pow(0.01 / d, 1.2);                                     //反函数实现发光效果，并使用幂函数来增强图像的整体对比度

        // col *= d;                                                //赋值col d的颜色
    
        finalColor += col * d;                                      //创建新的载体，为实现循环颜色奠定代码基础
    }

    fragColor = vec4(finalColor, 1.0);                              //输出颜色RGB，shadertoy里透明通道无意义
}