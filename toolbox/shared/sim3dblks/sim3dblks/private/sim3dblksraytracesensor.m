function[varargout]=sim3dblksraytracesensor(varargin)



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

    sim3d.utils.internal.SensorCallback.addSensorTag(Block);
    MaskObj=get_param(Block,'MaskObject');
    vehTag=MaskObj.getParameter('vehTag');
    set_param([Block,'/Simulation 3D Ray Tracer'],'VehicleIdentifier',vehTag.Value);

    ParamList={'SampleTime',[1,1],{'st',0};...
    'NumberOfBounces',[1,1],{'gte',0};};


    InportNames={'Hit locations','Hit normals','Hit distances','Surface ids','Is valid hit'};

    FoundNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport'),'Name');
    [~,PortI]=intersect(InportNames,FoundNames);
    PortI=sort(PortI);
    for i=1:length(PortI)
        set_param([Block,'/',InportNames{PortI(i)}],'Port',num2str(i));
    end

    checkSensorParameters(Block);
    SetMountLocation(Block,"Simulation 3D Ray Tracer");
    autoblkscheckparams(Block,ParamList);
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


    IconInfo.ImageName='sim3draytracesensor.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end