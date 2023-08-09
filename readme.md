
工业仿真软件的解码和二次开发。

# 部署

使用部署脚本`deploy.m`将`matlab_2022b_win_run.zip`解压到仓库，同名文件跳过。


# 平台
平台支持语言：英语，部分支持：中文、日语、韩语。
资源所在路径`resources/MATLAB/en{ja_JP}{ko_KR}`


## 关闭p文件解码后的警告
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

## 设置支持包的根路径
Matlab 运行时的外部路径包括：
```commandline
% C:\BaiduSyncdisk\workspace\demo
matlabshared.supportpkg.getSupportPackageRoot

% 用户的工作空间：C:\BaiduSyncdisk\matlab\software\matlab_utils\SupportPackages\R2022b
% 包括打开例子时拷贝的路径
userpath

% matlab 启动时的用户自定义配置的路径
```

## 附加文件
其他附件的文件包括支持包`SupportPackages`、软件`software`、示例`../demo`等。


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

