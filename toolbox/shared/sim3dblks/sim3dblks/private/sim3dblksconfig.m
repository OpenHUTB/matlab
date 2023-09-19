% 三维仿真模块的配置信息
function[varargout] = sim3dblksconfig(varargin)
    varargout{1}={};

    block = varargin{1};
    Context = varargin{2};
    switch Context
    case 'Initialization'
        Initialization(block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(block);
    case 'SetMountLocation'
        SetMountLocation(block);
    case 'MountOffsetToggle'
        MountOffsetToggle(block);
    case 'SetMainCameraName'
        SetMainCameraName(block);
    case 'SetMountPointOptions'
        SetMountPointOptions(block);
    case 'UpdateDropdowns'
        UpdateDropdowns(block);
    case 'ProjFrmtCallback'
        ProjFrmtCallback(block);
    case 'InitVehTagList'
        InitVehTagList(block);
    case 'SetSceneDesc'
        SetSceneDesc(block);
    case 'BrowseCallback'
        BrowseCallback(block);
    case 'OpenDRIVEBrowseCallback'
        OpenDRIVEBrowseCallback(block);
    case 'ScnBrowseCallback'
        ScnBrowseCallback(block);
    case 'ProjBrowseCallback'
        ProjBrowseCallback(block);
    case 'OpenUECallback'
        OpenUECallback(block);
    case 'SetScnPath'
        SetScnPath(block);
    case 'ProjPathCallback'
        ProjPathCallback(block);
    case 'SetProjName'
        SetProjName(block);
    case 'SetEnableWeather'  % 是否启用天气配置
        SetEnableWeather(block);
    case 'SetEnableRemoteAccess'
        SetEnableRemoteAccess(block);
    case 'SetEnableOpenDRIVE'
        SetEnableOpenDRIVE(block);
    case 'SetEnableGeospatial'
        SetEnableGeospatial(block);
    case 'AuthenticationManagerCallback'
        AuthenticationManagerCallback(block);
    case 'AdvancedSunConfigCallback'
        AdvancedSunConfigCallback(block);
    case 'DaylightSavingsTimeCallback'
        DaylightSavingsTimeCallback(block);
    case 'MapStyleCallback'
        MapStyleCallback(block);
    end
end


function IconInfo=DrawCommands(block)
    AliasNames={};
    IconInfo=autoblksgetportlabels(block,AliasNames);
    IconInfo.ImageName='sim3dscene_configuration.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,50,'white');
    if strcmp(get_param(block,'aMode'),'4')
        IconInfo.ImageName='sim3dscene_configuration_uav.png';
        [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,0,0,'white');

    elseif strcmp(get_param(block,'aMode'),'0')
        IconInfo.ImageName='sim3dscene_configuration_aero.png';
        [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,0,0,'white');
    end
end


function Initialization(block)
    SrcSelVeh=get_param(block,'OpVisEn');
    ConfgDispOptions={'sim3dcommon/Scene Config Term','Scene Config Term';...
    'sim3dcommon/Scene Config Ops','Scene Config Ops'};
    if strcmp(SrcSelVeh,'off')
        autoblksreplaceblock(block,ConfgDispOptions,1);
    else
        autoblksreplaceblock(block,ConfgDispOptions,2);
    end
    sim3d.utils.internal.MainCameraCallback.addSensorTag(block);
    maskObj=get_param(block,'MaskObject');
    vehTag=maskObj.getParameter('vehTag');
    set_param([block,'/Simulation 3D Main Camera'],'VehicleIdentifier',vehTag.Value);
    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')

        if(vehTag.Value=="Scene Origin")
            set_param([block,'/Simulation 3D Main Camera'],'Translation','[-6,0,2]');
            set_param([block,'/Simulation 3D Main Camera'],'Rotation','[0, -15, 0]');
        else
            set_param([block,'/Simulation 3D Main Camera'],'Translation','[0,0,0]');
            set_param([block,'/Simulation 3D Main Camera'],'Rotation','[0, 0, 0]');
        end
    end
    sceneDesc=maskObj.getParameter('SceneDesc');
    enableGeoSpatial=maskObj.getParameter('EnableGeospatial');
    originalMaps={...
        'shared_sim3dblks:sim3dblkConfig:StraightRoad';...
        'shared_sim3dblks:sim3dblkConfig:CurvedRoad';...
        'shared_sim3dblks:sim3dblkConfig:ParkingLot';...
        'shared_sim3dblks:sim3dblkConfig:DoubleLaneChange';...
        'shared_sim3dblks:sim3dblkConfig:OpenSurface';...
        'shared_sim3dblks:sim3dblkConfig:USCityBlock';...
        'shared_sim3dblks:sim3dblkConfig:USHighway';...
        'shared_sim3dblks:sim3dblkConfig:VirtualMcity';...
        'shared_sim3dblks:sim3dblkConfig:LargeParkingLot';...
        'shared_sim3dblks:sim3dblkConfig:Airport';...
        'shared_sim3dblks:sim3dblkConfig:EmptyScene';...
        'shared_sim3dblks:sim3dblkConfig:Geospatial',...
    };
    aMode=get_param(block,'aMode');
    ASBMaps={'Airport'};
    GeospatialMap={'Geospatial'};
    VDBSADTMaps={...
        'shared_sim3dblks:sim3dblkConfig:StraightRoad';...
        'shared_sim3dblks:sim3dblkConfig:CurvedRoad';...
        'shared_sim3dblks:sim3dblkConfig:ParkingLot';...
        'shared_sim3dblks:sim3dblkConfig:DoubleLaneChange';...
        'shared_sim3dblks:sim3dblkConfig:OpenSurface';...
        'shared_sim3dblks:sim3dblkConfig:USCityBlock';...
        'shared_sim3dblks:sim3dblkConfig:USHighway';...
        'shared_sim3dblks:sim3dblkConfig:VirtualMcity';...
        'shared_sim3dblks:sim3dblkConfig:LargeParkingLot';...
    };
    UAVMaps={'shared_sim3dblks:sim3dblkConfig:USCityBlock'};
    SL3DMaps={'shared_sim3dblks:sim3dblkConfig:EmptyScene'};
    MapsFolder=fullfile(userpath,'sim3d_project',['R',version('-release')],'WindowsNoEditor/AutoVrtlEnv/Content/Paks/');
    MapsFolderExist=dir(MapsFolder);

    if~isempty(MapsFolderExist)
        pakFiles=dir(fullfile(MapsFolder,'*.pak'));
        NumberOfMaps=length(pakFiles);
        types=[];

        for i=NumberOfMaps:-1:1
            mapName=sim3d.utils.internal.ScenesMapping.getMapName(pakFiles(i).name);
            if~isempty(mapName)
                types=[types;mapName];
            end
        end

        if~isempty(types)
            originalMaps={originalMaps;types};
            ASBMaps={ASBMaps;types};
            VDBSADTMaps={VDBSADTMaps;types};
            UAVMaps={UAVMaps;types};
            SL3DMaps={SL3DMaps;types};
        end
    end
    sceneDesc.TypeOptions=originalMaps;
    if strcmp(aMode,'0')
        sceneDesc.TypeOptions=ASBMaps;
    elseif(strcmp(aMode,'2')||strcmp(aMode,'3'))
        sceneDesc.TypeOptions=VDBSADTMaps;
    elseif strcmp(aMode,'4')
        sceneDesc.TypeOptions=UAVMaps;
    elseif strcmp(aMode,'5')
        sceneDesc.TypeOptions=SL3DMaps;
    end
    if(strcmp(enableGeoSpatial.Value,"on"))
        sceneDesc.TypeOptions=GeospatialMap;
    end
    configureMount(block);
    SetProjName(block);
    EnableGeoSpatialTab(block);
end


function EnableGeoSpatialTab(block)
    maskObj=get_param(block,'MaskObject');
    amode=maskObj.getParameter('aMode');
    geoSpatialTab=maskObj.getDialogControl('GeospatialTab');
    if(strcmp(amode.Value,'0'))
        geoSpatialTab.Visible='on';
    end
end


function InitVehTagList(block)
    maskObj=get_param(block,'MaskObject');
    vehTagList=maskObj.getParameter('vehTagList');
    vehTag=maskObj.getParameter('vehTag');
    vehTag.TypeOptions=eval(vehTagList.Value);
end


function ProjFrmtCallback(block)
    SrcSelection=get_param(block,'ProjectFormat');
    maskObj=get_param(block,'MaskObject');
    opueBtn=maskObj.getDialogControl('openUEButton');
    ueproj=maskObj.getParameter('UEProjPath');

    if strcmp(SrcSelection,getString(message('shared_sim3dblks:sim3dblkConfig:DefaultScenes')))
        autoblksenableparameters(block,{'vehTag','SceneDesc','EnableWindow'},{'ProjectName','OpenDRIVEName','ScenePath','UEProjPath','EnableOpenDRIVE'},...
        '',{'BrowseBtn','ScnBrowseBtn','OpenDRIVEBrowseBtn','ProjBrowseBtn','openUEButton'});
    elseif strcmp(SrcSelection,getString(message('shared_sim3dblks:sim3dblkConfig:UnrealExecutable')))
        openDRIVECheckBox=maskObj.getParameter('EnableOpenDRIVE');
        if strcmp(openDRIVECheckBox.Value,'off')
            autoblksenableparameters(block,{'vehTag','ProjectName','ScenePath','EnableWindow','EnableOpenDRIVE'},{'OpenDRIVEName','SceneDesc','UEProjPath'},...
            {'BrowseBtn','ScnBrowseBtn'},{'ProjBrowseBtn','openUEButton','OpenDRIVEBrowseBtn'});
        else
            autoblksenableparameters(block,{'vehTag','ProjectName','ScenePath','EnableWindow','EnableOpenDRIVE','OpenDRIVEName'},{'SceneDesc','UEProjPath'},...
            {'BrowseBtn','ScnBrowseBtn','OpenDRIVEBrowseBtn'},{'ProjBrowseBtn','openUEButton'});
        end
    elseif strcmp(SrcSelection,getString(message('shared_sim3dblks:sim3dblkConfig:UnrealEditor')))
        openDRIVECheckBox=maskObj.getParameter('EnableOpenDRIVE');
        if strcmp(openDRIVECheckBox.Value,'off')
            autoblksenableparameters(block,{'vehTag','UEProjPath','EnableOpenDRIVE'},{'SceneDesc','ProjectName','ScenePath','EnableWindow','EnableRemoteAccess','OpenDRIVEName'},...
            {'ProjBrowseBtn','openUEButton'},{'BrowseBtn','ScnBrowseBtn','OpenDRIVEBrowseBtn'});
        else
            autoblksenableparameters(block,{'vehTag','UEProjPath','EnableOpenDRIVE','OpenDRIVEName'},{'SceneDesc','ProjectName','ScenePath','EnableWindow','EnableRemoteAccess'},...
            {'ProjBrowseBtn','openUEButton','OpenDRIVEBrowseBtn'},{'BrowseBtn','ScnBrowseBtn'});
        end

        expression='([a-zA-Z0-9\s_\\.\-\(\):])+(.uproject)$';
        FoundMatch=regexp(ueproj.Value,expression,'once');

        if isempty(FoundMatch)
            opueBtn.Enabled='off';
        else
            opueBtn.Enabled='on';
        end
    end

end


function SetSceneDesc(block)
    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')
        maskObj=get_param(block,'MaskObject');
        sceneDesc=maskObj.getParameter('SceneDesc');
        set_param([block,'/Simulation 3D Engine'],'SceneDesc',sceneDesc.Value);
    end
end


function BrowseCallback(block)
    [fileName,pathName,~] = uigetfile({'*.exe';'*.*'}, 'Pick a Unreal Engine Executable Project');
    if fileName ~= 0
        set_param(block, 'ProjectName',fullfile(pathName,fileName));
    end
end


function OpenDRIVEBrowseCallback(block)
    [fileName,pathName,~]=uigetfile({'*.xodr';'*.*'},'Pick an OpenDRIVE file');
    if fileName~=0
        set_param(block,'OpenDRIVEName',fullfile(pathName,fileName));
    end
end


function SetProjName(block)
    switch get_param(block,"ProjectFormat")
    case getString(message('shared_sim3dblks:sim3dblkConfig:DefaultScenes'))
        set_param(block,"ProjectName",sim3d.engine.Env.AutomotiveExe());
    case getString(message('shared_sim3dblks:sim3dblkConfig:UnrealExecutable'))
        projectName=get_param(block,"ProjectName");

        if~isfile(projectName)
            error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidFileName'));
        end
    end
end


function ScnBrowseCallback(block)
    [fileName,pathName,~]=uigetfile({'*.umap';'*.*'},'Pick a Unreal Engine Scene');
    if fileName~=0
        fullPath=fullfile(pathName,fileName);
        newPath=extractBetween(fullPath,'Content','.umap');
        if~isempty(newPath)
            strSp=split(newPath,filesep);
            prePath='/Game';
            for i=2:length(strSp)
                spPath=['/',strSp{i}];
                prePath=[prePath,spPath];
            end
        end
        set_param(block, 'ScenePath',prePath);  % 给模块设置可执行场景文件
    end
end


function ProjBrowseCallback(block)
    [fileName,pathName,~]=uigetfile({'*.uproject';'*.*'},'Pick a Unreal Engine Project');

    if fileName~=0
        set_param(block,'UEProjPath',fullfile(pathName,fileName));
        opueBtn.Enabled='on';
    else
        opueBtn.Enabled='off';
    end
end


function SetScnPath(block)
    maskObj = get_param(block,'MaskObject');
    scenePath = maskObj.getParameter('ScenePath');  % 可执行场景文件的绝对路径
    SrcSelection=get_param(block,'ProjectFormat');

    if strcmp(SrcSelection, getString(message('shared_sim3dblks:sim3dblkConfig:UnrealExecutable')))
        set_param([block,'/Simulation 3D Engine'], 'SceneDesc',scenePath.Value);
    end
end


% 使用虚幻编辑器进行联合仿真的回调函数
function OpenUECallback(block)
    maskObj=get_param(block,'MaskObject');
    projPath = maskObj.getParameter('UEProjPath');
    opueBtn=maskObj.getDialogControl('openUEButton');
    projectPath = projPath.Value;

    if CheckUprojectAssociationAndSignalAbort()
        return;
    end

    p=System.Diagnostics.Process.GetProcessesByName('UE4Editor');
    if p.Length
        answer=questdlg(...
        getString(message('shared_sim3dblks:sim3dblkConfig:popup_UE_instance_dialog')),...
        getString(message('shared_sim3dblks:sim3dblkConfig:popup_UE_instance_title')),...
        getString(message('shared_sim3dblks:sim3dblkConfig:popup_yes')),...
        getString(message('shared_sim3dblks:sim3dblkConfig:popup_no')),...
        getString(message('shared_sim3dblks:sim3dblkConfig:popup_cancel')),...
        getString(message('shared_sim3dblks:sim3dblkConfig:popup_cancel'))...
        );
        if strcmp(answer,getString(message('shared_sim3dblks:sim3dblkConfig:popup_yes')))
            opueBtn.Enabled='on';
            editor = sim3d.engine.Editor(projectPath);
            status = editor.open();
        end
    else
        opueBtn.Enabled='on';
        editor=sim3d.engine.Editor(projectPath);
        status=editor.open();

    end
end


% 项目路径(.project)处理
function ProjPathCallback(block)
    SrcSelection = get_param(block, 'ProjectFormat');

    if strcmp(SrcSelection, getString(message('shared_sim3dblks:sim3dblkConfig:UnrealEditor')))

        maskObj = get_param(block, 'MaskObject');
        opueBtn=maskObj.getDialogControl('openUEButton');
        ueproj=maskObj.getParameter('UEProjPath');

        expression = '([a-zA-Z0-9\s_\\.\-\(\):])+(.uproject)$';
        FoundMatch = regexp(ueproj.Value,expression,'once');

        if isempty(FoundMatch)
            opueBtn.Enabled='off';
        else
            opueBtn.Enabled='on';
        end
    end
end


function configureMount(block)
    cameraAtSceneOrigin=strcmp(get_param(block,"vehTag"),"Scene Origin");
    simulationStatus=get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus,'running')
        if cameraAtSceneOrigin
            set_param(string(block)+"/"+"Simulation 3D Main Camera","Translation","[-6, 0 , 2]");
            set_param(string(block)+"/"+"Simulation 3D Main Camera","Rotation","[0, -15, 0]");
        else
            SetMountLocation(block,"Simulation 3D Main Camera");
        end
    end
end


% 启用天气设置的处理
function SetEnableWeather(block)
    maskObj = get_param(block,'MaskObject');
    enWeather = maskObj.getParameter('EnableWeather');
    pWeather = maskObj.getDialogControl('WeatherParas');
    simulationStatus = get_param(bdroot,'SimulationStatus');
    if~strcmp(simulationStatus, 'running')
        if strcmp(enWeather.Value, 'on')
            pWeather.Enabled = 'on';
        else
            pWeather.Enabled='off';
        end
    end
    SetSelectWeather(block);
    set_param([block,'/Simulation 3D Engine'], 'EnableWeather', enWeather.Value);
end


function SetSelectWeather(block)
    maskObj=get_param(block,'MaskObject');
    sunaltitude=maskObj.getParameter('SunAltitude');
    sunazimuth=maskObj.getParameter('SunAzimuth');
    wind=maskObj.getParameter('wind');
    clouds=maskObj.getParameter('clouds');
    fog=maskObj.getParameter('fog');
    rain=maskObj.getParameter('rain');

    weatherid=strcat('[',sunaltitude.Value,',',sunazimuth.Value,',',clouds.Value,',',fog.Value,',',rain.Value,',',wind.Value,']');
    set_param([block,'/Simulation 3D Engine'],'WeatherConfigParas',weatherid);
end


function SetEnableRemoteAccess(block)
    maskObj=get_param(block,'MaskObject');
    enRemoteAccess=maskObj.getParameter('EnableRemoteAccess');
    set_param([block,'/Simulation 3D Engine'],'EnableRemoteAccess',enRemoteAccess.Value);
end


function SetEnableOpenDRIVE(block)
    maskObj=get_param(block,'MaskObject');
    enMetaData=maskObj.getParameter('EnableOpenDRIVE');
    if strcmp(enMetaData.Value,'on')
        autoblksenableparameters(block,{'OpenDRIVEName'},{},{'OpenDRIVEBrowseBtn'},{});
    else
        autoblksenableparameters(block,{},{'OpenDRIVEName'},{},{'OpenDRIVEBrowseBtn'});
    end

end

function abort=CheckUprojectAssociationAndSignalAbort()
    abort=false;

    try
        sim3d.utils.internal.checkWindowsUprojectAssociation()
    catch ME
        if strcmp(ME.identifier,"Sim3d:InvalidUprojectAssociation")
            answer=questdlg(...
            getString(message('shared_sim3dblks:sim3dblkConfig:popup_unexpected_association_dialog')),...
            getString(message('shared_sim3dblks:sim3dblkConfig:popup_unexpected_association_title')),...
            getString(message('shared_sim3dblks:sim3dblkConfig:popup_yes')),...
            getString(message('shared_sim3dblks:sim3dblkConfig:popup_no')),...
            getString(message('shared_sim3dblks:sim3dblkConfig:popup_no'))...
            );

            abort=strcmp(answer,getString(message('shared_sim3dblks:sim3dblkConfig:popup_no')));
        end
    end
end


function AuthenticationManagerCallback(~)
    AuthManager=sim3d.geospatial.AuthManager();
    action=questdlg('Select action',...
    'Manage access tokens',...
    'Create token','Update token','Remove token','Update token');

    switch action
    case 'Create token'
        userInput=inputdlg({'Token ID','Token value'},'Create new token',[1,50;1,50]);
        if(isempty(userInput))
            return;
        end
        if(~isempty(userInput{1})&&~isempty(userInput{2}))
            AuthManager.addToken(userInput{1},userInput{2});
        end
    case 'Update token'
        tokenList=AuthManager.getAvailableTokenIDs();
        [indx,~]=listdlg('PromptString','Select a token ID to update...',...
        'SelectionMode','single','ListString',tokenList);
        if(isempty(indx))
            return;
        end
        userInput=inputdlg({'Token value'},['Update token value of ',tokenList{indx}],[1,50]);
        if(~isempty(userInput{1}))
            AuthManager.updateToken(tokenList{indx},userInput{1});
        end
    case 'Remove token'
        userInput=inputdlg({'Token ID'},'Remove token',[1,50]);
        if(isempty(userInput))
            return;
        end
        if(~isempty(userInput{1}))
            AuthManager.removeToken(userInput{1});
        end
    end
end


function AdvancedSunConfigCallback(block)
    maskObj=get_param(block,'MaskObject');
    useSunConfig=maskObj.getParameter('UseAdvancedSunSky');
    sunConfigPanel=maskObj.getDialogControl('SunParams');
    if(strcmp(useSunConfig.Value,'on'))
        sunConfigPanel.Expand='on';
        sunConfigPanel.Enabled='on';
    else
        sunConfigPanel.Expand='off';
        sunConfigPanel.Enabled='off';
    end
end


function DaylightSavingsTimeCallback(block)
    maskObj=get_param(block,'MaskObject');
    useDST=maskObj.getParameter('UseDaylightSavingTime');
    dstConfigPanel=maskObj.getDialogControl('DSTParams');
    if(strcmp(useDST.Value,'on'))
        dstConfigPanel.Enabled='on';
    else
        dstConfigPanel.Enabled='off';
    end
end


function SetEnableGeospatial(block)
    simulationStatus=get_param(bdroot,'SimulationStatus');
    if strcmp(simulationStatus,'running')
        return;
    end
    maskObj=get_param(block,'MaskObject');
    enableGeoSpatial=maskObj.getParameter('EnableGeospatial');
    accessTokenParam=maskObj.getParameter('AccessTokenID');
    advancedSunParam=maskObj.getParameter('UseAdvancedSunSky');
    geoRefTab=maskObj.getDialogControl('GeoRefParams');
    tilesetTab=maskObj.getDialogControl('TilesetParams');
    sunTab=maskObj.getDialogControl('SunParams');
    authManagerParam=maskObj.getDialogControl('AuthManager');
    enWeather=maskObj.getParameter('EnableWeather');
    if(strcmp(enableGeoSpatial.Value,"off"))
        accessTokenParam.Enabled='off';
        advancedSunParam.Enabled='off';
        geoRefTab.Enabled='off';
        tilesetTab.Enabled='off';
        set_param(block,'UseAdvancedSunSky','off');
        sunTab.Enabled='off';
        authManagerParam.Enabled='off';

        enWeather.Enabled='on';
    else
        accessTokenParam.Enabled='on';
        advancedSunParam.Enabled='on';
        geoRefTab.Enabled='on';
        tilesetTab.Enabled='on';
        authManagerParam.Enabled='on';


        set_param(block,'EnableWeather','off');
        enWeather.Enabled='off';
    end
end


function MapStyleCallback(block)
    maskObj=get_param(block,'MaskObject');
    mapStyleOuter=maskObj.getParameter('MapStyle');
    innerBlock=[block,'/GeoSpatialSwitch/GeoSpatialSubsystem/Simulation3DGeoSpatial'];
    mapStyleInnerValue=2;
    switch mapStyleOuter.Value
    case 'Aerial'
        mapStyleInnerValue=2;
    case 'Aerial with labels'
        mapStyleInnerValue=3;
    case 'Road'
        mapStyleInnerValue=4;
    end
    set_param(innerBlock,'MapStyle',num2str(mapStyleInnerValue));
end

