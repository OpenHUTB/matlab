function[varargout]=sim3dblks3dveh(varargin)

    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'VehicleSelection'
        VehicleSelection(Block);
    case 'VehLightsControl'
        VehLightsControl(Block);
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


function IconInfo=DrawCommands(Block)
    AliasNames={'X','X';'Y','Y';'Yaw','Yaw'};
    IconInfo=autoblksgetportlabels(Block,AliasNames);
    IconInfo.ImageName='sim3dvehtxfrm.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end


function VehicleSelection(Block)
    MaskObj=get_param(Block,'MaskObject');
    VehMesh=MaskObj.getParameter('PassVehMesh');
    MeshPath=MaskObj.getParameter('MeshPath');
    MeshPath.Visible='off';
    if(strcmp(VehMesh.Value,'Custom'))
        MeshPath.Visible='on';
    end
end


function Initialization(Block)
    sim3d.utils.SimPool.addActorTag(Block);
    MaskObj=get_param(Block,'MaskObject');
    vehName=MaskObj.getParameter('ActorTag');
    set_param([Block,'/Simulation 3D Vehicle'],'ActorTag',vehName.Value);
    ParamList={'SampleTime',[1,1],{'st',0};...
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
    autoblkscheckparams(Block,ParamList);
    MeshPath=MaskObj.getParameter('MeshPath');
    set_param([Block,'/Simulation 3D Vehicle'],'MeshPath',MeshPath.Value);
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

end