function[varargout]=sim3dblksdepthsensor(varargin)



    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};

    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'MountOffsetToggle'
        MountOffsetToggle(Block);
    case 'SetSensorName'
        SetSensorName(Block);
    case 'SetMountPointOptions'
        SetMountPointOptions(Block);
    case 'UpdateDropdowns'
        UpdateDropdowns(Block);
    case 'InitVehTagList'
        InitVehTagList(Block);
    end
end

function Initialization(Block)
    GrayscaleOutportEnabled=get_param(Block,'GrayscaleOutportEnabled');
    GrayscaleOutportOptions={'simulink/Sinks/Terminator','Grayscale Terminator';...
    'simulink/Sinks/Out1','Grayscale'};

    if strcmp(GrayscaleOutportEnabled,'off')
        autoblksreplaceblock(Block,GrayscaleOutportOptions,1);
    else
        autoblksreplaceblock(Block,GrayscaleOutportOptions,2);
    end

    sim3d.utils.internal.SensorCallback.addSensorTag(Block);
    MaskObj=get_param(Block,'MaskObject');
    vehTag=MaskObj.getParameter('vehTag');
    set_param([Block,'/Simulation 3D Depth Sensor'],'VehicleIdentifier',vehTag.Value);

    checkSensorParameters(Block);
    SetMountLocation(Block,"Simulation 3D Depth Sensor");
end

function InitVehTagList(block)
    maskObj=get_param(block,'MaskObject');
    vehTagList=maskObj.getParameter('vehTagList');
    vehTag=maskObj.getParameter('vehTag');
    vehTag.TypeOptions=eval(vehTagList.Value);
end

function IconInfo=DrawCommands(Block)

    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='sim3ddepth.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end