function[varargout]=sim3dblksultrasonicsensorarray(varargin)

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

function Initialization(block)
    sim3d.utils.internal.SensorCallback.addSensorTag(block);
    MaskObj=get_param(block,'MaskObject');
    vehTag=MaskObj.getParameter('vehTag');
    set_param([block,'/Simulation 3D Ultrasonic Array'],'VehicleIdentifier',vehTag.Value);

    ParamList={'SampleTime',[1,1],{'st',0};...
    'DetectionRangesInMeters',[1,3],{'gt',0};};

    ConfigureOutputPorts(block);
    checkSensorParameters(block);
    SetMountLocation(block,"Simulation 3D Ultrasonic Array");
    autoblkscheckparams(block,ParamList);
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


    IconInfo.ImageName='sim3d_ultrasonic_sensor.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end

function ConfigureOutputPorts(block)
    DetectionsOptions={...
    'simulink/Sinks/Terminator','Detections terminator';...
    'simulink/Sinks/Out1','Detections'...
    };

    HasObjectOptions={...
    'simulink/Sinks/Terminator','Has object terminator';...
    'simulink/Sinks/Out1','Has object'...
    };

    HasRangeOptions={...
    'simulink/Sinks/Terminator','Has range terminator';...
    'simulink/Sinks/Out1','Has range'...
    };

    RangeOptions={...
    'simulink/Sinks/Terminator','Range terminator';...
    'simulink/Sinks/Out1','Range'...
    };

    useBusOutput=get_param(block,"useBusOutput");
    if strcmp(useBusOutput,'off')
        autoblksreplaceblock(block,DetectionsOptions,1);
        autoblksreplaceblock(block,HasObjectOptions,2);
        autoblksreplaceblock(block,HasRangeOptions,2);
        autoblksreplaceblock(block,RangeOptions,2);
    else
        autoblksreplaceblock(block,DetectionsOptions,2);
        autoblksreplaceblock(block,HasObjectOptions,1);
        autoblksreplaceblock(block,HasRangeOptions,1);
        autoblksreplaceblock(block,RangeOptions,1);
    end
end