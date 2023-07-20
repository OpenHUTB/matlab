function[varargout]=sim3dblks3dvehterrfbVDBS(varargin)



    varargout{1}={};

    Block=varargin{1};

    Context=varargin{2};
    switch Context
    case 'Initialization'
        varargout{1}=Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'VehicleSelection'
        VehicleSelection(Block);
    case 'VehLightsControl'
        VehLightsControl(Block);
    end
end

function IconInfo=DrawCommands(Block)

    AliasNames={'X','X';'Y','Y';'Yaw','Yaw'};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='sim3dvehicle.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end

function VehicleSelection(Block)
    MaskObj=get_param(Block,'MaskObject');
    VehMesh=MaskObj.getParameter('PassVehMesh');
    MaskObj.getDialogControl('CustomMeshProperties').Visible='off';
    if(strcmp(VehMesh.Value,'Custom'))
        MaskObj.getDialogControl('CustomMeshProperties').Visible='on';
    end
end

function VehLightsControl(Block)

    LightsEnabled=get_param(Block,'VehLightsControl');
    p=Simulink.Mask.get(Block);
    if strcmp(LightsEnabled,'off')
        p.getDialogControl('HeadlightSettingsMenu').Enabled='off';
        p.getDialogControl('BrakelightSettingsMenu').Enabled='off';
        p.getDialogControl('ReverselightSettingsMenu').Enabled='off';
        p.getDialogControl('SignallightSettingsMenu').Enabled='off';
        p.getDialogControl('HeadlightSettingsMenu').Expand='off';
        p.getDialogControl('BrakelightSettingsMenu').Expand='off';
        p.getDialogControl('ReverselightSettingsMenu').Expand='off';
        p.getDialogControl('SignallightSettingsMenu').Expand='off';
    else
        p.getDialogControl('HeadlightSettingsMenu').Enabled='on';
        p.getDialogControl('BrakelightSettingsMenu').Enabled='on';
        p.getDialogControl('ReverselightSettingsMenu').Enabled='on';
        p.getDialogControl('SignallightSettingsMenu').Enabled='on';
        p.getDialogControl('HeadlightSettingsMenu').Expand='on';
        p.getDialogControl('BrakelightSettingsMenu').Expand='on';
        p.getDialogControl('ReverselightSettingsMenu').Expand='on';
        p.getDialogControl('SignallightSettingsMenu').Expand='on';
    end
end
function ParamStruct=Initialization(Block)
    BlkHdl=get_param(Block,'Handle');


    vehType=get_param(BlkHdl,'PassVehMesh');
    MaskObj=get_param(Block,'MaskObject');
    TrackWidth=MaskObj.getParameter('TrackWidth');
    WheelBase=MaskObj.getParameter('WheelBase');
    WheelRadius=MaskObj.getParameter('WheelRadius');
    switch vehType
    case 'Muscle car'
        ParamStruct.WheelRadius=0.369;
        ParamStruct.WheelBase=3.02;
    case 'Sedan'
        ParamStruct.WheelRadius=0.350;
        ParamStruct.WheelBase=2.82;
    case 'Sport utility vehicle'
        ParamStruct.WheelRadius=0.401;
        ParamStruct.WheelBase=2.90;
    case 'Small pickup truck'
        ParamStruct.WheelRadius=0.446;
        ParamStruct.WheelBase=3.69;
    case 'Hatchback'
        ParamStruct.WheelRadius=0.306;
        ParamStruct.WheelBase=2.45;
    case 'Box truck'
        ParamStruct.WheelRadius=0.350;
        ParamStruct.WheelBase=5.5;
    otherwise
        ParamStruct.WheelRadius=eval(WheelRadius.Value);
        ParamStruct.WheelBase=eval(WheelBase.Value);
    end
    debug=0;
    if debug==1
        fprintf('The "%s" has a wheel radius of %0.3g m and a wheelbase of %0.3g m.',...
        vehType,ParamStruct.WheelRadius,ParamStruct.WheelBase);
    end


    sim3d.utils.SimPool.addActorTag(Block);
    vehName=MaskObj.getParameter('ActorTag');
    set_param([Block,'/Simulation 3D Vehicle'],'ActorTag',vehName.Value);
    ParamList={'SampleTime',[1,1],{'st',0};...
    'TrackWidth',[1,1],{'gt',0};...
    'WheelBase',[1,1],{'gt',0};...
    'WheelRadius',[1,1],{'gt',0};...
    'InitialPos',[1,3],{};...
    'InitialRot',[1,3],{};...
    'HeadlightColor',[1,3],{'gte',0;'lte',1};...
    'HighBeamIntensity',[1,1],{'gte',0};...
    'LowBeamIntensity',[1,1],{'gte',0};...
    'HighBeamConeAngle',[1,1],{'gt',0;'lte',pi/2};...
    'LowBeamConeAngle',[1,1],{'gt',0;'lte',pi/2};...
    'LeftHeadlightOrientation',[1,2],{'gte',-pi;'lte',pi};...
    'RightHeadlightOrientation',[1,2],{'gte',-pi;'lte',pi};...
    'BrakelightIntensity',[1,1],{'gte',0};...
    'ReverselightIntensity',[1,1],{'gte',0};...
    'SignallightIntensity',[1,1],{'gte',0};...
    'SignallightPeriod',[1,1],{};...
    'SignalPulseWidth',[1,1],{};};



    MeshPath=MaskObj.getParameter('MeshPath');
    set_param([Block,'/Simulation 3D Vehicle'],'MeshPath',MeshPath.Value);

    set_param([Block,'/Simulation 3D Vehicle'],'TrackWidth',TrackWidth.Value);
    set_param([Block,'/Simulation 3D Vehicle'],'WheelBase',WheelBase.Value);
    set_param([Block,'/Simulation 3D Vehicle'],'WheelRadius',WheelRadius.Value);



    LightsEnabled=get_param(Block,'VehLightsControl');
    LightsInportOptions={'built-in/Constant','LightStates';...
    'simulink/Sources/In1','Light controls'};
    if strcmp(LightsEnabled,'off')
        autoblksreplaceblock(Block,LightsInportOptions,1);
        set_param([Block,'/LightStates'],'Value','zeros(1,6)');
        set_param([Block,'/Simulation 3D Vehicle'],'EnableLightControls','false');
    else
        autoblksreplaceblock(Block,LightsInportOptions,2);
        set_param([Block,'/Simulation 3D Vehicle'],'EnableLightControls','true');
    end
    autoblkscheckparams(Block,ParamList);
end