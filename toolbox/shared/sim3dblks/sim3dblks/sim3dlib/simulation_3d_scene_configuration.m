% 初始化代码区
function initialization()
    sim3dblkssharedicon('sim3dblksconfig',gcb,'Initialization');  % gcb获取当前模块的路径名称
end


%% 参数回调区

% ProjectFormat 的回调
function ProjectFormat_callback()
    sim3dblkssharedicon('sim3dblksconfig',gcb,'ProjFrmtCallback');
end

% SceneDesc 的回调
function SceneDesc_callback()
    sim3dblkssharedicon('sim3dblksconfig', gcb, 'SetSceneDesc');
end


% BrowseBtn 的回调
function BrowseBtn_callback()
    sim3dblkssharedicon('sim3dblksconfig',gcb,'BrowseCallback');
end


% 场景路径 ScenePath 的回调
function ScenePath_callback()
    sim3dblkssharedicon('sim3dblksconfig', gcb, 'SetScnPath');
end

% Callback for ScnBrowseBtn
function ScnBrowseBtn_callback()
sim3dblkssharedicon('sim3dblksconfig',gcb,'ScnBrowseCallback');
end

% Callback for UEProjPath
function UEProjPath_callback()
sim3dblkssharedicon('sim3dblksconfig',gcb,'ProjPathCallback');
end

% Callback for ProjBrowseBtn
function ProjBrowseBtn_callback()
sim3dblkssharedicon('sim3dblksconfig',gcb,'ProjBrowseCallback');
end

% Callback for EnableOpenDRIVE
function EnableOpenDRIVE_callback()
    sim3dblkssharedicon('sim3dblksconfig',gcb,'SetEnableOpenDRIVE');
end

% Callback for OpenDRIVEBrowseBtn
function OpenDRIVEBrowseBtn_callback()
sim3dblkssharedicon('sim3dblksconfig',gcb,'OpenDRIVEBrowseCallback');
end

% Callback for vehTagList
function vehTagList_callback()
sim3dblkssharedicon('sim3dblksconfig', gcb, 'InitVehTagList');

end

% Callback for vehTag
function vehTag_callback()
sim3dblkssharedicon('sim3dblksconfig', gcb, 'SetMountPointOptions');
end

% Callback for EnableWindow
function EnableWindow_callback()
sim3dblkssharedicon('sim3dblksconfig',gcb,'ProjFrmtCallback');
end

% Callback for openUEButton
function openUEButton_callback()
sim3dblkssharedicon('sim3dblksconfig',gcb,'OpenUECallback');
end

% Callback for EnableRemoteAccess
function EnableRemoteAccess_callback()
sim3dblkssharedicon('sim3dblksconfig',gcb,'SetEnableRemoteAccess');
end

% Callback for EnableWeather
function EnableWeather_callback()
sim3dblkssharedicon('sim3dblksconfig',gcb,'SetEnableWeather');
end

% Callback for EnableGeospatial
function EnableGeospatial_callback()
sim3dblkssharedicon('sim3dblksconfig', gcb, 'SetEnableGeospatial');
end

% Callback for MapStyle
function MapStyle_callback()
sim3dblkssharedicon('sim3dblksconfig', gcb, 'MapStyleCallback');
end

% Callback for UseAdvancedSunSky
function UseAdvancedSunSky_callback()
sim3dblkssharedicon('sim3dblksconfig', gcb, 'AdvancedSunConfigCallback');
end

% Callback for UseDaylightSavingTime
function UseDaylightSavingTime_callback()
sim3dblkssharedicon('sim3dblksconfig', gcb, 'DaylightSavingsTimeCallback');
end

% Callback for AuthManager
function AuthManager_callback()
sim3dblkssharedicon('sim3dblksconfig', gcb, 'AuthenticationManagerCallback');
end

% Callback for sensorId
function sensorId_callback()
sim3dblkssharedicon('sim3dblksconfig', gcb, 'SetMainCameraName');

end

% Callback for offsetFlag
function offsetFlag_callback()
sim3dblkssharedicon('sim3dblksconfig', gcb, 'MountOffsetToggle');
end