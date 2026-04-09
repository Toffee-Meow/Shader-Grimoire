//去除UE引擎对模型贴图自动添加的色调映射
//HLSL代码放入材质蓝图Custom节点里使用
//占位头文件
//custom节点隐式包含了一个
//auto Custom(){
//编写的内容
//}
//通过return 1;}使得Custom函数直接返回1并终止
//这样就可以include色调映射文件给接下来的函数使用了
//而此时多出来的一个}就需要创建一个无作用的void aaaaa(){去把它抵消掉，否则会报错
//也就是说这个aaaaa函数的唯一作用就是无害化custom节点隐式包含的最后一个}

return 1;
}
//#include "Random.ush"
//#include "Common.ush"
//#include "PostProcessCommon.ush"
//#include "TonemapCommon.ush"

#include "/Engine/Private/TonemapCommon.ush"

void aaaaa(){