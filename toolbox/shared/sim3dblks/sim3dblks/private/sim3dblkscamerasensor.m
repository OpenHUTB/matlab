function[varargout]=sim3dblkscamerasensor(varargin)

    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};

    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'MountOffsetToggle'
        sim3dCameraMountOffsetToggle(Block);
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
    simStopped=autoblkschecksimstopped(Block);
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
    DepthOutportEnabled=get_param(Block,'DepthOutportEnabled');
    DepthOutportOptions={'simulink/Sinks/Terminator','Depth Terminator';...
    'simulink/Sinks/Out1','Depth'};

    if strcmp(DepthOutportEnabled,'off')
        autoblksreplaceblock(Block,DepthOutportOptions,1);
    else
        autoblksreplaceblock(Block,DepthOutportOptions,2);
    end
    SemanticOutportEnabled=get_param(Block,'SemanticOutportEnabled');
    SemanticOutportOptions={'simulink/Sinks/Terminator','Semantic Terminator';...
    'simulink/Sinks/Out1','Semantic'};

    if strcmp(SemanticOutportEnabled,'off')
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
    if simStopped
        if strcmp(get_param(Block,'offsetFlag'),'off')
            set_param(Block,'extTmount','off');
            set_param(Block,'extRmount','off');
        end
        if strcmp(get_param(Block,'extTmount'),'off')
            SwitchPort(Block,'Rel Translation','Constant','single([0 0 0])');
        else
            SwitchPort(Block,'Rel Translation','Inport',[]);
            set_param([Block,'/Rel Translation'],'Unit','m');
        end
        if strcmp(get_param(Block,'extRmount'),'off')
            SwitchPort(Block,'Rel Rotation','Constant','single([0 0 0])');
        else
            SwitchPort(Block,'Rel Rotation','Inport',[]);
            set_param([Block,'/Rel Rotation'],'Unit','deg');
        end
    end
    sim3d.utils.internal.SensorCallback.addSensorTag(Block);
    MaskObj=get_param(Block,'MaskObject');
    vehTag=MaskObj.getParameter('vehTag');
    set_param([Block,'/Simulation 3D Camera'],'VehicleIdentifier',vehTag.Value);
    InportNames={'Image','Depth','Semantic','Translation','Rotation'};
    FoundNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport'),'Name');
    [~,PortI]=intersect(InportNames,FoundNames);
    PortI=sort(PortI);
    for i=1:length(PortI)
        set_param([Block,'/',InportNames{PortI(i)}],'Port',num2str(i));
    end

    checkSensorParameters(Block);
    SetMountLocation(Block,"Simulation 3D Camera");
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
    IconInfo.ImageName='sim3dpinhole.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end


function sim3dCameraMountOffsetToggle(Block)
    if strcmp(get_param(Block,'offsetFlag'),'on')

        autoblksenableparameters(Block,{'tmountOffset','rmountOffset','extTmount','extRmount'});
    else

        autoblksenableparameters(Block,{},{'tmountOffset','rmountOffset','extTmount','extRmount'});
    end
    sim3dblkscamerasensor(Block,'ExtOffsetInputs');
end


function SwitchPort(Block,PortName,UsePort,Param)

    InportOption={'built-in/Constant',[PortName,'Constant'];...
    'built-in/Inport',PortName;...
    'simulink/Sinks/Terminator',[PortName,'Terminator'];...
    'simulink/Sinks/Out1',PortName;...
    'built-in/Ground',[PortName,'Ground']};
    switch UsePort
    case 'Constant'
        NewBlkHdl=autoblksreplaceblock(Block,InportOption,1);
        set_param(NewBlkHdl,'Value',Param,'VectorParams1D','off');
    case 'Terminator'
        autoblksreplaceblock(Block,InportOption,3);
    case 'Outport'
        autoblksreplaceblock(Block,InportOption,4);
    case 'Inport'
        autoblksreplaceblock(Block,InportOption,2);
    case 'Ground'
        autoblksreplaceblock(Block,InportOption,5);
    end

    InportNames={'Rel Translation';'Rel Rotation'};
    OutportNames={'Image','Depth','Semantic','Translation','Rotation'};
    FoundInNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
    [~,PortI]=intersect(InportNames,FoundInNames);
    FoundOutNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport'),'Name');
    [~,PortO]=intersect(OutportNames,FoundOutNames);
    PortI=sort(PortI);
    PortO=sort(PortO);
    for i=1:length(PortI)
        set_param([Block,'/',InportNames{PortI(i)}],'Port',num2str(i));
    end
    for i=1:length(PortO)
        set_param([Block,'/',OutportNames{PortO(i)}],'Port',num2str(i));
    end
end
