%% 使用 Simulink 将 RoadRunner 场景导入虚幻引擎
% 此示例演示如何使用 Simulink® 将 RoadRunner 中内置的场景导入到虚幻引擎® 仿真环境中。该示例还展示了如何在仿真过程中生成视觉检测、真实语义分割标签和深度数据。
% 
% 您可以使用 <docid:sl3d_ref#mw_96a521fd-316f-497b-bc01-b2c5f4083563 Simulation 3D 
% Scene Configuration> 模块导入 RoadRunner 场景。您可以将此示例中的仿真数据与其他传感器数据结合使用来开发和验证自动驾驶算法。 
%% 打开模型
% 打开 Simulink 模型。

open_system("RoadRunnerSceneImport");
%% 探索模型
% 该模型模拟 RoadRunner 场景中的两辆车。该模型包括一个 Simulation 3D Scene Configuration 模块，两个 Simulation 
% 3D Vehicle with Ground Following 模块，一个 Simulation 3D Camera 模块和一个 Simulation 
% 3D Vision Detection Generator 模块。
% 
% <docid:sl3d_ref#mw_96a521fd-316f-497b-bc01-b2c5f4083563 Simulation 3D Scene 
% Configuration> 模块实现三维仿真环境。对于本示例，该模块导入 RoadRunner 场景进行仿真。 
% 
% 当您按照 Simulation 3D Scene Configuration 模块的 <docid:sl3d_ref#mw_1ac25a0f-ee92-44f0-b220-d9ccbe5b04bd 
% *Project*> 参数中所述导出 RoadRunner 场景时，文件夹中会提供三个文件：  
%% 
% * Filmbox (|.fbx|) 文件
% * XML (|.rrdata.xml|) 文件
% * ASAM OpenDrive (|.xodr|) 文件
%% 
% 要打开 Block Parameters 对话框，双击模块。要导入 RoadRunner 场景，*Scene source* 设置为 |RoadRunner，并将| 
% *Project* 指定为 Filmbox (|.fbx|) 文件。
% 
% 
% 
% <docid:driving_ref#mw_32cd8e72-2d69-4c3e-98b0-5b918db383a4 Simulation 3D Vehicle 
% with Ground Following> 模块在场景中实现了两辆车，|Vehicle1| 和 |Vehicle2|。输入 X, Y, 和 Yaw 具有固定值，|Vehicle1| 
% 的位置在 |Vehicle2| 之后。
% 
% <docid:driving_ref#mw_e9491451-3198-4988-8ef1-6a3878d29155 Simulation 3D Camera> 
% 模块安装在相对于 |Vehicle1| 的相对位置，并输出仿真期间捕获的图像。要打开“模块参数”对话框，请双击模块。要指定安装位置，请在 *Mounting* 
% 选项卡中将 *Mounting location* 选择为 |Origin|。选择 *Specify offset* 复选框以设置相机的相对平移 *Relative 
% translation* 和相对旋转 *Relative rotation*。
% 
% 
% 
% 为了获取深度数据和语义分割数据，在 *Ground Truth* 选项卡下选择 *Output depth* 和 *Output semantic 
% segmentation*。 该模块使用 XML (|.rrdata.xml|) 文件在导入期间将标签（语义类型）应用到 RoadRunner 场景。 
% 该模块使用 <docid:vision_ref#f14522 To Video Display> 模块输出相机、深度、语义分割显示。
% 
% <docid:driving_ref#mw_e07bfe36-17d0-4326-b961-8c7c2aa0fc71 Simulation 3D Vision 
% Detection Generator> 模块通过安装在 |Vehicle1| 后视镜上的视觉传感器生成车道和物体检测。该模块使用 ASAM OpenDrive 
% (|.xodr|) 文件来获取车道检测数据。
%% 探索仿真数据
% 在仿真模型之前，请查看深度、语义分割和视觉检测的数据。
% 深度数据
% |深度图|是相机传感器输出的灰度表示。这些地图以灰度形式可视化相机图像，较亮的像素表示距离传感器较远的物体。您可以使用深度图来验证传感器的深度估计算法。
% 
% Simulation 3D Camera 模块的 *Depth* 端口输出 0 到 1000 米范围内的值的深度图。在此模型中，为了提高可见性，饱和度模块将深度输出饱和到最大 
% 150 米。然后，Gain 模块将深度图缩放到范围 [0, 1]，以便 To Video Display 模块可以以灰度形式可视化深度图。
% 语义分割数据
% |语义分割|描述了将图像的每个像素与类别标签（例如道路、建筑物或交通标志）相关联的过程。三维仿真环境根据标签分类方案生成合成语义分割数据。您可以使用这些标签来训练自动驾驶应用的神经网络，例如道路分割。通过可视化语义分割数据，您可以验证您的分类方案。
% 
% Simulation 3D Camera 模块的 *Semantic* 端口使用XML (|.rrdata.xml|) 为输出相机图像每一个像素输出一组标签。每个标签对应一个对象类。例如，在模块使用的默认分类方案中，标签1对应于建筑物。该标签0引用未知类别的对象并显示为黑色。有关标签 
% ID 及其相应对象描述的完整列表，请参阅 <docid:driving_ref#mw_e5aa15be-422f-494d-b196-1dc1811d68ef 
% Labels>。
% 
% MATLAB Function 模块使用 <docid:images_ref#f6-333611 |label2rgb|> 函数将标签转换为 RGB 
% 三元组矩阵以进行可视化。颜色映射到默认三维仿真场景中使用的预定义标签 ID。帮助函数 |sim3dColormap| 定义颜色映射。 
% 视觉检测数据
% |视觉检测|可用于建模或仿真驾驶场景。对于视觉检测数据，您可以使用 <docid:driving_ref#mw_59742eb7-dce8-4938-9c2e-44d34c7b8891 
% Bird's-Eye Scope> 查看视觉传感器的覆盖区域、物体检测和视觉传感器的车道检测。*Object Detections* 端口显示视觉覆盖区域中的任何对象。*Lane 
% Detections* 端口使用导入的 ASAM OpenDrive (|.xodr|) 文件检测车道。
% 
% 要查看视觉检测，请在开始仿真之前设置鸟瞰范围 Bird's-Eye Scope。Bird's-Eye Scope 是一个模型级可视化工具，您可以从 
% Simulink 工具条中打开它。在 *Simulation* 选项卡上的 *Review Results*, 单击 *Bird's-Eye Scope*。打开示波器后，单击 
% *Find Signals* 以设置信号。然后，运行仿真以显示车辆、视觉检测和车道检测。
%% 仿真模型
% 仿真以在 Simulation 3D Viewer 窗口中查看导入的包含两辆车的 RoadRunner 场景。仿真开始时，Simulation 3D 
% Viewer 窗口将显示包含两辆车的 RoadRunner 场景。
% 
% 在 Simulation 3D Viewer 窗口后面，您可以查看相机、深度、语义分割和视觉检测的显示。
% 相机显示
% Simulation 3D Camera 模块的 *Image* 端口输出仿真的三维相机图像。
% 深度显示
% 
% 语义分割展示
% 
% 视觉检测显示
%