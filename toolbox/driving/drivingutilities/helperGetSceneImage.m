function [sceneImage, sceneRef] = helperGetSceneImage(sceneName)
%helperGetSceneImage 获得场景图像和空间参考
%   [sceneImage, sceneRef] = helperGetSceneImage(sceneName) 检索与 sceneName 
%   指定的场景相关联的图像和空间参考。
%   sceneName 必须是指定场景名称的字符串标量或字符向量。
%   sceneImage 是一个真实颜色的RGB图像。
%   sceneRef 是一个 imref2d 类型的空间参考对象，用于描述内在图像坐标和世界坐标之间的关系。 
%
%   注意
%   -----
%   sceneName 必须是有效的三维仿真引擎场景的名称，并且可以是以下内容之一： 
%   "LargeParkingLot", "ParkingLot",
%   "DoubleLaneChange", "USCityBlock", "USHighway", "CurvedRoad",
%   "VirtualMCity", "StraightRoad", "OpenSurface".
%
%   示例：读取并显示虚拟城市（Virtual M-City）图像
%   ---------------------------------------------------
%   % 获得虚拟城市（Virtual M-City）场景图像和空间参考
%   sceneName = 'VirtualMCity';
%   [sceneImage, sceneRef] = helperGetSceneImage(sceneName);
%
%   % 显示图像
%   figure
%   imshow(sceneImage, sceneRef)
%   xlabel('X (m)')
%   ylabel('Y (m)')
%   title(sceneName)
%
%   % Set Y-direction back to normal
%   set(gca, 'YDir', 'normal')
%
%   参见 imref2d.


% 验证场景名称
supportedScenes = {'LargeParkingLot', 'ParkingLot', 'DoubleLaneChange', ...
    'USCityBlock', 'USHighway', 'CurvedRoad', 'VirtualMCity', 'StraightRoad', ...
    'OpenSurface'};

% 检查场景名（sceneName）是否在一组支持的场景名（supportedScenes）中
sceneName = validatestring(sceneName, supportedScenes, mfilename, 'sceneName');

% 读取指定场景名的图像（比如：matlab\examples\driving_ros\data\sim3d_LargeParkingLot.jpg）
imageName = strcat('sim3d_', sceneName, '.jpg');
sceneImage = imread(imageName);  % 5928*5928*3

% 读取空间参考
data = load('sim3d_SpatialReferences.mat');
sceneRef = data.spatialReference.(sceneName);  % 利用.()来找出结构体中指定变量的元素（5104*5014，这和场景图片大小不一致）
end