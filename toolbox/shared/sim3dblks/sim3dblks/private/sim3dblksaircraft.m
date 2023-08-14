function[varargout]=sim3dblksaircraft(varargin)




    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'Mesh'
        MeshDependencies(Block);
    case 'AltitudeSensor'
        AltitudeSensor(Block);
    case 'LightConfiguration'
        LightConfiguration(Block);
    end
end

function MeshDependencies(Block)

    block_h=getSimulinkBlockHandle(Block);
    maskObj=Simulink.Mask.get(block_h);
    mesh=get_param(block_h,'Mesh');
    meshPath=maskObj.getParameter('MeshPath');
    meshPathAT=maskObj.getParameter('MeshPathAT');
    meshPathGA=maskObj.getParameter('MeshPathGA');
    ncols=3;
    nrows=11;
    meshPath.Visible='off';
    meshPathAT.Visible='off';
    meshPathGA.Visible='off';
    switch mesh
    case 'Sky Hogg'
        nrows=11;
    case 'Airliner'
        nrows=12;
    case 'General aviation'
        nrows=15;
        meshPathGA.Visible='on';
    case 'Air transport'
        nrows=30;
        meshPathAT.Visible='on';
    case 'Custom'
        nrows=57;
        meshPath.Visible='on';
    end


    cs=sprintf('[%d, %d]',nrows,ncols);
    ccs=get_param([Block,'/Translation'],'PortDimensions');
    if~strcmp(ccs,cs)
        set_param([Block,'/Translation'],'PortDimensions',cs);
        set_param([Block,'/Rotation'],'PortDimensions',cs);
    end

    LightConfiguration(Block);
end

function AltitudeSensor(Block)

    block_h=getSimulinkBlockHandle(Block);
    maskObj=Simulink.Mask.get(block_h);
    viz=get_param(block_h,'IsGHSensorEnabled');
    i1=10;
    [maskObj.Parameters(i1:i1+5).Visible]=deal(viz);
end

function LightConfiguration(Block)

    block_h=getSimulinkBlockHandle(Block);
    maskObj=Simulink.Mask.get(block_h);
    lightsConfig=get_param(block_h,'LightsConfig');
    landingPanel=maskObj.getDialogControl('LandingLightsPanel');
    taxiPanel=maskObj.getDialogControl('TaxiLightsPanel');
    navPanel=maskObj.getDialogControl('NavLightsPanel');
    posPanel=maskObj.getDialogControl('PosLightsPanel');
    strobePanel=maskObj.getDialogControl('StrobeLightsPanel');
    beaconPanel=maskObj.getDialogControl('BeaconLightsPanel');
    landingPanel.Visible='off';
    taxiPanel.Visible='off';
    navPanel.Visible='off';
    posPanel.Visible='off';
    strobePanel.Visible='off';
    beaconPanel.Visible='off';
    viz=false;
    if strcmp(lightsConfig,'Configurable lights')
        viz=true;
        landingPanel.Visible='on';
        taxiPanel.Visible='on';
        navPanel.Visible='on';
        posPanel.Visible='on';
        strobePanel.Visible='on';
        beaconPanel.Visible='on';
    end


    mesh=get_param(block_h,'Mesh');
    np=36;
    enabled=true(1,np);

    switch mesh
    case 'Sky Hogg'
        enabled(23:26)=false;
        taxiPanel.Visible='off';
        enabled(28)=false;
        posPanel.Visible='off';
        enabled(30:31)=false;
        enabled(19:22)=false;
        enabled(25:26)=false;

    case 'Airliner'
        enabled(28)=false;
        posPanel.Visible='off';
        enabled(19:22)=false;
        enabled(25:26)=false;


    case 'General aviation'
    case 'Air transport'
    case 'Custom'
    end

    for i=17:np
        maskObj.Parameters(i).Visible=matlab.lang.OnOffSwitchState(viz&enabled(i)).char();
        maskObj.Parameters(i).Enabled=matlab.lang.OnOffSwitchState(enabled(i)).char();
    end
end

function IconInfo=DrawCommands(Block)

    aliasNames={'Translation','Translation';'Rotation','Rotation'};
    IconInfo=autoblksgetportlabels(Block,aliasNames);


    IconInfo.ImageName='aeroblksim3d.svg';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end

function Initialization(Block)

    sim3d.utils.SimPool.addActorTag(Block);
    maskObj=get_param(Block,'MaskObject');
    vehName=maskObj.getParameter('ActorTag');
    set_param([Block,'/Simulation 3D Aircraft'],'ActorTag',vehName.Value);
    paramList={'SampleTime',[1,1],{'st',0};};
    autoblkscheckparams(Block,paramList);


    isOutportEnabled=get_param(Block,'IsGHSensorEnabled');
    outport1Options={'simulink/Sinks/Terminator','Alt Terminator';...
    'simulink/Sinks/Out1','Altitude'};
    outport2Options={'simulink/Sinks/Terminator','WoW Terminator';...
    'simulink/Sinks/Out1','WoW'};
    if strcmp(isOutportEnabled,'off')
        autoblksreplaceblock(Block,outport1Options,1);
        autoblksreplaceblock(Block,outport2Options,1);
    else
        autoblksreplaceblock(Block,outport1Options,2);
        autoblksreplaceblock(Block,outport2Options,2);
    end


    lightsConfig=get_param(Block,'LightsConfig');
    inportOptions={'simulink/Sources/Ground','Lights Ground';...
    'simulink/Sources/In1','LightStates'};
    if lightsConfig~="Configurable lights"
        autoblksreplaceblock(Block,inportOptions,1);
    else
        autoblksreplaceblock(Block,inportOptions,2);
    end
end