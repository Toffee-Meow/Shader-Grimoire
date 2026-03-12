//去除UE引擎对模型贴图自动添加的色调映射
//HLSL代码放入材质蓝图Custom节点里使用

return FilmToneMapInverse(col);