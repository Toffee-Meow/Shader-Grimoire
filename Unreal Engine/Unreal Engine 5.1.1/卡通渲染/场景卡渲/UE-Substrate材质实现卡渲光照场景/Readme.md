## UE-Substrate材质实现卡渲光照场景

引擎版本：UE 5.1.1

UE5.1.1_Strata_SSS MEP

### 内容

&emsp;&emsp;基于Substrate（UE5.1的版本为Strata）材质系统，编写硬表面和贴花材质，配合Strata的次表面散射平均自由程（SSS MFP）属性，实现次表面散射光照的卡渲场景

&emsp;&emsp;最终渲染画面：卡通材质+灯光+后期处理调色

### 资产

&emsp;&emsp;资产内容为材质蓝图

&emsp;&emsp;材质蓝图：硬表面主材质、贴花材质

- M_CustomMask_51.uasset：硬表面主材质
- M_CustomMask_51.uasset：主贴花材质（RGB通道）
- M_CustomMask_G_51.uasset：G通道贴花材质
- M_CustomMask_R_51.uasset：R通道贴花材质

> PS：UE资产文件，导入项目Content文件夹内使用
> 
> 文件名最后的数字表示编写材质球所使用的引擎版本

### 内容预览

> 引擎渲染效果
<div align="center">
<p>
<img src="Preview/Strata材质卡渲光照场景_全景.png" alt="Strata材质卡渲光照场景_全景" title="Strata材质卡渲光照场景_全景" />
</p>
</div>

> 材质节点预览
<div align="center">
<p>
<img src="Preview/硬表面主材质预览.png" alt="硬表面主材质预览" title="硬表面主材质预览" />
</p>
</div>