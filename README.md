
工业仿真软件的注释和二次开发。

# 部署

递归克隆项目：
```shell
git clone --recursive https://github.com/OpenHUTB/matlab.git
```
或者更新子模块：
```shell
git submodule update --init --recursive
```

然后使用部署脚本`deploy.m`将`matlab_2022b_win_run.zip`解压的文件部署到仓库中（同名文件跳过）。


# 定制

## 关闭使用.m文件替换后的警告
```
warning('query','last')
```
显示p文件所在目录包含m文件所对应的警告信息
```
identifier: 'MATLAB:pfileOlderThanMfile'
state: 'on'
```
关闭警告
```
warning('off', 'MATLAB:pfileOlderThanMfile')
```

## 增加新示例
1. 根据文档中的打开示例的命令（如：`openExample('sl3d/CreateActorInWorldSceneExample')`在新版本软件中打开并找到`.mlx`文件；
2. 复制到示例目录下，如`{matlab_root}\examples\sl3d\main`（注：文件名不修改）；
3. 在`{matlab_root}\examples\sl3d\examples.xml`中增加示例的元信息；
4. 使用命令进行测试。
```shell
openExample('sl3d/CreateActorInWorldSceneExample
```


## 设置支持包的根路径
Matlab 运行时的外部路径包括：
```shell
matlabshared.supportpkg.getSupportPackageRoot

% 用户的工作空间：{matlabroot}\software\matlab_utils\SupportPackages\R2022b
% 包括打开例子时拷贝的路径
userpath
% matlab 启动时的用户自定义配置的路径
```

## 附加文件
其他附件的文件包括支持包`SupportPackages`、软件`software`、示例`../demo`等。

### 支持包
* 量子计算
```shell
{matlab_root}\SupportPackages\toolbox\matlab\quantum
```

* git代码管理
将功能添加到系统路径当中
```shell
addpath(fullfile(toolboxdir('matlab'), 'git'))
savepath
```



## 解码经验
1. 脚本中出现`R36`表示声明函数参数验证
比如（`matlab\toolbox\shared\sim3d\sim3d\+sim3d\World.m`中的`setup()`）：
```shell
arguments
    self sim3d.World
    sampleTime(1,1) single{mustBePositive}
end
```

* 将`enumeration`错误解码为`emumeration`。



2. simulink模块选中后，通过“模块”菜单中的“查看封装”，再查看“代码”选项卡可以看到代码（其中的函数调用`matlab\toolbox\shared\sim3dblks\sim3dblks`中的脚本。
并且通过“模块”菜单中的“查看基础封装”中的“查看基础封装内部”，可以查看模块内部的连接信息。

3. 内置函数：比如查看`sort`函数（`toolbox\matlab\datafun\sort.m`）
```shell
edit sort
```
对应源代码位于：`toolbox/matlab/datatypes/categorical/@categorical/sort.m`

### Simulink
选中模块，菜单栏中“模块”->查看封装内部。

#### 三维仿真
三维仿真库：`toolbox\shared\sim3dblks\sim3dblks\sim3dlib.slx`。

自动驾驶虚拟环境（Automotive Virtual Environment）：`matlab\SupportPackages\toolbox\shared\sim3dprojects\spkg\project\AutoVrtlEnv\AutoVrtlEnv.uproject`。
`AutoVrtlEnv\Binaries\Win64\UE4Editor-AutoVrtlEnv.pdb`是指“程序数据库”（Program Data Base）文件，是VS编译链接时生成的文件，主要存储了VS调试程序时所需要的基本信息，主要包括源文件名、变量名、函数名、FPO(帧指针)、对应的行号等等。PDB文件是在编译工程的时候产生的，它是和对应的模块（UE4Editor-AutoVrtlEnv.dll）一起生成出来的。因为存储的是调试信息，所以一般情况下PDB文件是在Debug模式下才会生成。

PDB文件中记录了源文件路径的相关信息，所以在载入PDB文件的时候，就可以将相关调试信息与源码对应。这样可以可视化的实时查看调试时的函数调用、变量值等相关信息。模块当中记录的PDB文件是绝对路径。所以只要模块在当前电脑上载入，调试器自然地会根据模块当中的路径信息找到相应PDB文件并载入。同样PDB文件中记录的源文件路径也是绝对路径，所以PDB文件只要在当前电脑上载入，调试进入相应模块时，都能够匹配到记录的源文件，然后可视化地查看相应信息。

### 工具
开源[cutter](https://github.com/rizinorg/cutter) 。

[IDA](https://soft.macxf.com/soft/2059.html?id=MTcyMDc1%20) 。

[教程](https://wizardforcel.gitbooks.io/re-for-beginners/content/) 。+

## 维护

### 覆盖本地的文件
```shell
git fetch --all
git reset --hard origin/master  # 将本地仓库的HEAD指针、工作目录和暂存区回滚到指定远程分支（origin/master）的状态
```

# 计划
* 调用修改后的系统类，出现：`未找到具有匹配签名的方法 :all:`。
即：`No method with matching signature.`

原因：同名情况下，内部函数优先。


* 编程实现.mlx中清除输出结果；

* 界面快捷键：Alt+D选中地址栏；

* 虚拟机中测试环境搭建；

# 平台
平台支持语言：英语，部分支持：汉语、日语、韩语。
资源所在路径`resources/MATLAB/en{zh_CN}{ja_JP}{ko_KR}`

# 参考
## 工具
[颜色命名器](https://products.aspose.app/svg/zh/color-names) 

## 更新
[新版本所加的特性](https://ww2.mathworks.cn/help/driving/release-notes.html)

2023a新增加的例子
```commandline
openExample('driving/CreateTopDownVisualizationDuringAnUnrealEngineSimulationExample')
openExample('scenariobuilder/EgoVehicleLocalizationUsingGPSAndIMUFusionExample')
openExample('scenariobuilder/EgoLocalizationUsingLaneDetectionsAndHDMapExample')
openExample('scenariobuilder/GenerateRoadSceneWithLanesFromLabeledRecordedDataExample')
openExample('driving_fusion_scenariobuilder/FuseRecordedLidarAndCameraDataForScenarioGenerationExample')
openExample('autonomous_control/TranslocateRoadRunnerCollisionScenarioToSelectedSceneExample')
openExample('driving/SetDefaultBasemapForHEREHDLiveMapLayerDataExample')
openExample('shared_vision_driving/PathPlanningUsing3DLidarMapExample')
openExample('autonomous_control/LaneLevelPathPlanningWithRRScenarioExample')
openExample('autonomous_control/PlatooningWithRRScenarioExample')
openExample('autonomous_control/AEBWithHighFidelityDynamicsExample')
```
深度学习
```commandline
openExample('deeplearning_shared/WorkWithDeepLearningDataInAzureBlobStorageExample')
openExample('nnet/SequenceClassificationCustomTrainingLoopExample')
openExample('nnet/OutofDistributionDetectionForDeepNeuralNetworksExample')
https://github.com/matlab-deep-learning/quantization-aware-training
openExample('deeplearning_shared/OutofDistributionDiscriminatorForYOLOV4ObjectDetectorExample')
openExample('deeplearning_shared/ExploreQuantizedSemanticSegmentationNetworkUsingGradCAMExample')
openExample('deeplearning_shared/QuantizeNetworkTrainedForSemanticSegmentationExample')
https://ww2.mathworks.cn/help/deeplearning/ug/detect-issues-while-training-deep-neural-network.html
openExample('deeplearning_shared/DetectPCBDefectsUsingYOLOV4Example')
openExample('images_deeplearning/CardiacLeftVentricleSegmentationFromCineMRIImagesExample')
```

