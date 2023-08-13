function[varargout]=sim3dblksmotorcycle(varargin)

    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'MotorcycleLightsControl'
        MotorcycleLightsControl(Block);
    end
end

function MotorcycleLightsControl(Block)

    LightsEnabled=get_param(Block,'MotorcycleLightsControl');
    p=Simulink.Mask.get(Block);
    if strcmp(LightsEnabled,'off')
        p.getDialogControl('HeadlightSettingsMenu').Enabled='off';
        p.getDialogControl('BrakelightSettingsMenu').Enabled='off';
        p.getDialogControl('SignallightSettingsMenu').Enabled='off';
        p.getDialogControl('HeadlightSettingsMenu').Expand='off';
        p.getDialogControl('BrakelightSettingsMenu').Expand='off';
        p.getDialogControl('SignallightSettingsMenu').Expand='off';
    else
        p.getDialogControl('HeadlightSettingsMenu').Enabled='on';
        p.getDialogControl('BrakelightSettingsMenu').Enabled='on';
        p.getDialogControl('SignallightSettingsMenu').Enabled='on';
        p.getDialogControl('HeadlightSettingsMenu').Expand='on';
        p.getDialogControl('BrakelightSettingsMenu').Expand='on';
        p.getDialogControl('SignallightSettingsMenu').Expand='on';
    end
end

function IconInfo=DrawCommands(Block)

    AliasNames={'Translation','Translation';'Rotation','Rotation';'Scale','Scale'};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='sim3dmotorcycle.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end

function Initialization(Block)
    sim3d.utils.SimPool.addActorTag(Block);
    MaskObj=get_param(Block,'MaskObject');
    vehName=MaskObj.getParameter('ActorTag');
    set_param([Block,'/Simulation 3D Motorcycle'],'ActorTag',vehName.Value);
    ParamList={'SampleTime',[1,1],{'st',0};...
    'HeadlightColor',[1,3],{'gte',0;'lte',1};...
    'HighBeamIntensity',[1,1],{'gte',0};...
    'LowBeamIntensity',[1,1],{'gte',0};...
    'HighBeamConeAngle',[1,1],{'gt',0;'lte',pi/2};...
    'LowBeamConeAngle',[1,1],{'gt',0;'lte',pi/2};...
    'HeadlightOrientation',[1,2],{'gte',-pi;'lte',pi};...
    'BrakelightIntensity',[1,1],{'gte',0};...
    'SignallightIntensity',[1,1],{'gte',0};...
    'SignallightPeriod',[1,1],{};...
    'SignalPulseWidth',[1,1],{};...
    };




    LightsEnabled=get_param(Block,'MotorcycleLightsControl');
    LightsInportOptions={'built-in/Constant','LightStates';...
    'simulink/Sources/In1','Light controls'};
    if strcmp(LightsEnabled,'off')
        autoblksreplaceblock(Block,LightsInportOptions,1);
        set_param([Block,'/LightStates'],'Value','zeros(1,5)');
        set_param([Block,'/Simulation 3D Motorcycle'],'EnableLightControls','false');
    else
        autoblksreplaceblock(Block,LightsInportOptions,2);
        set_param([Block,'/Simulation 3D Motorcycle'],'EnableLightControls','true');
    end

    autoblkscheckparams(Block,ParamList);
end