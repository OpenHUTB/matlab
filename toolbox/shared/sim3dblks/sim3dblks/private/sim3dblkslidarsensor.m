function[varargout]=sim3dblkslidarsensor(varargin)



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

    blkMask=Simulink.Mask.get(Block);
    mountLocParam=findobj(blkMask.Parameters,'Name','mountLoc');
    offsetFlagParam=findobj(blkMask.Parameters,'Name','offsetFlag');

    if(strcmp(get_param(Block,'aMode'),'4'))
        mountLocParam.Enabled='off';
        offsetFlagParam.Value='on';
        offsetFlagParam.Enabled='off';
    else
        mountLocParam.Enabled='on';
        offsetFlagParam.Enabled='on';
    end

    DistanceOutportEnabled=get_param(Block,'DistanceOutportEnabled');
    DistanceOutportOptions={'simulink/Sinks/Terminator','Distance Terminator';...
    'simulink/Sinks/Out1','Distance'};

    if strcmp(DistanceOutportEnabled,'off')
        autoblksreplaceblock(Block,DistanceOutportOptions,1);
    else
        autoblksreplaceblock(Block,DistanceOutportOptions,2);
    end

    ReflectivityOutportEnabled=get_param(Block,'ReflectivityOutportEnabled');
    ReflectivityOutportOptions={'simulink/Sinks/Terminator','Reflectivity Terminator';...
    'simulink/Sinks/Out1','Reflectivity'};

    if(strcmp(ReflectivityOutportEnabled,'off'))
        autoblksreplaceblock(Block,ReflectivityOutportOptions,1);
    else
        autoblksreplaceblock(Block,ReflectivityOutportOptions,2);
    end

    SemanticOutportEnabled=get_param(Block,'SemanticOutportEnabled');
    SemanticOutportOptions={'simulink/Sinks/Terminator','Semantic Terminator';...
    'simulink/Sinks/Out1','Semantic'};

    if(strcmp(SemanticOutportEnabled,'off'))
        autoblksreplaceblock(Block,SemanticOutportOptions,1);
    else
        autoblksreplaceblock(Block,SemanticOutportOptions,2);
    end

    TransformOutportEnabled=get_param(Block,'TransformOutportEnabled');
    TranslationOutportOptions={'simulink/Sinks/Terminator','Translation Terminator';...
    'simulink/Sinks/Out1','Translation'};

    if strcmp(TransformOutportEnabled,'off')
        autoblksreplaceblock(Block,TranslationOutportOptions,1);
    else
        autoblksreplaceblock(Block,TranslationOutportOptions,2);
    end

    RotationOutportOptions={'simulink/Sinks/Terminator','Rotation Terminator';...
    'simulink/Sinks/Out1','Rotation'};
    if strcmp(TransformOutportEnabled,'off')
        autoblksreplaceblock(Block,RotationOutportOptions,1);
    else
        autoblksreplaceblock(Block,RotationOutportOptions,2);
    end

    sim3d.utils.internal.SensorCallback.addSensorTag(Block);
    MaskObj=get_param(Block,'MaskObject');
    vehTag=MaskObj.getParameter('vehTag');
    set_param([Block,'/Simulation 3D Lidar'],'VehicleIdentifier',vehTag.Value);


    InportNames={'Point cloud','Distance','Reflectivity','Semantic','Translation','Rotation'};

    FoundNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport'),'Name');
    [~,PortI]=intersect(InportNames,FoundNames);
    PortI=sort(PortI);
    for i=1:length(PortI)
        set_param([Block,'/',InportNames{PortI(i)}],'Port',num2str(i));
    end

    checkSensorParameters(Block);
    SetMountLocation(Block,"Simulation 3D Lidar");
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


    IconInfo.ImageName='sim3dlidar.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end