function[varargout]=sim3dblks3dphysvehVDBS(varargin)

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
        VehLightsControl(Block,strcmp(get_param(Block,'VehLightsControl'),'on'));
    case 'Hndbrk'
        HndbrkUpdate(Block,strcmp(get_param(Block,'HndBrkEnable'),'on'));
    case 'TransCntrlType'
        Transcntrl(Block,strcmp(get_param(Block,'TransType'),'Automatic'));
    case 'DrivetrainType'
        DrivetrainType(Block,strcmp(get_param(Block,'DrivetrainType'),'All Wheel Drive'));
    case 'FrntHndbrk'
        FrntHndbrk(Block,strcmp(get_param(Block,'FrntWhlHndBrkEnable'),'on'));
    case 'RearHndbrk'
        RearHndbrk(Block,strcmp(get_param(Block,'RearWhlHndBrkEnable'),'on'));
    end
end


function IconInfo=DrawCommands(Block)
    AliasNames={'Steer','Steer';'Accel','Accel';'Decel','Decel';'Gear','Gear';'HndBrk','HndBrk';};
    IconInfo=autoblksgetportlabels(Block,AliasNames);
    IconInfo.ImageName='sim3dphysicalvehicle.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,0,0,'white');
end


function VehicleSelection(Block)
    MaskObj=get_param(Block,'MaskObject');
    VehMesh=MaskObj.getParameter('PassVehMesh');
    MaskObj.getDialogControl('CustomMeshProperties').Visible='off';
    if(strcmp(VehMesh.Value,'Custom'))
        MaskObj.getDialogControl('CustomMeshProperties').Visible='on';
    end
end


function VehLightsControl(Block,LightsEnabled)
    if LightsEnabled
        autoblksenableparameters(Block,[],[],{'HeadlightSettingsMenu';'BrakelightSettingsMenu';'ReverselightSettingsMenu';'SignallightSettingsMenu'},[]);
    else
        autoblksenableparameters(Block,[],[],[],{'HeadlightSettingsMenu';'BrakelightSettingsMenu';'ReverselightSettingsMenu';'SignallightSettingsMenu'});
    end
end


function ParamStruct=Initialization(Block)
    BlkHdl=get_param(Block,'Handle');
    HandbrakeEnabled=strcmp(get_param(Block,'HndBrkEnable'),'on');
    LightsEnabled=strcmp(get_param(Block,'VehLightsControl'),'on');
    VehLightsControl(Block,LightsEnabled);
    HndbrkUpdate(Block,HandbrakeEnabled);
    automaticTransType=strcmp(get_param(Block,'TransType'),'Automatic');
    Transcntrl(Block,automaticTransType);
    DrivetrainType(Block,strcmp(get_param(Block,'DrivetrainType'),'All Wheel Drive'));
    FrntHndbrk(Block,strcmp(get_param(Block,'FrntWhlHndBrkEnable'),'on'));
    RearHndbrk(Block,strcmp(get_param(Block,'RearWhlHndBrkEnable'),'on'));
    sim3d.utils.SimPool.addActorTag(Block);
    MaskObj=get_param(Block,'MaskObject');
    vehName=MaskObj.getParameter('ActorTag');
    set_param([Block,'/PhysicalVehicle'],'ActorTag',vehName.Value);
    ParamList={'SampleTime',[1,1],{'st',0};...
    'TrackWidth',[1,1],{'gt',0};...
    'WheelBase',[1,1],{'gt',0};...
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
    'SignalPulseWidth',[1,1],{};...
    'Mass',[1,1],{'gt',0};...
    'Cd',[1,1],{'gte',0};...
    'MaxRPM',[1,1],{'gt',0};...
    'Jmot',[1,1],{'gt',0};...
    'bEngMin',[1,1],{'gte',0};...
    'bEngMax',[1,1],{'gte',0};...
    'bEngN',[1,1],{'gte',0};...
    'ChassisHeight',[1,1],{'gt',0};...
    'IvehScale',[1,3],{'gt',0};...
    'CgOffset',[1,3],{};...
    'FrontRearSplit',[1,1],{'gte',0;'lte',1};...
    'tShift',[1,1],{'gt',0};...
    'tMinShift',[1,1],{'gt',0};...
    'NDiff',[1,1],{'gt',0};...
    'PctAck',[1,1],{'gt',0};...
    'FrntWhlRadius',[1,1],{'gt',0};...
    'FrntWhlMass',[1,1],{'gt',0};...
    'FrntWhlDamping',[1,1],{'gte',0};...
    'FrntWhlMaxSteer',[1,1],{'gte',0};...
    'FrntTireMaxLatLoadFactor',[1,1],{'gt',0};...
    'FrntTireLatStiff',[1,1],{'gt',0};...
    'FrntTireLongStiff',[1,1],{'gt',0};...
    'RearWhlRadius',[1,1],{'gt',0};...
    'RearWhlMass',[1,1],{'gt',0};...
    'RearWhlDamping',[1,1],{'gte',0};...
    'RearWhlMaxSteer',[1,1],{'gte',0};...
    'RearTireMaxLatLoadFactor',[1,1],{'gt',0};...
    'RearTireLatStiff',[1,1],{'gt',0};...
    'RearTireLongStiff',[1,1],{'gt',0};...
    'FrntWhlMaxTrq',[1,1],{'gt',0};...
    'RearWhlMaxTrq',[1,1],{'gt',0};...
    'FrntWhlMaxHndBrkTrq',[1,1],{'gt',0};...
    'RearWhlMaxHndBrkTrq',[1,1],{'gt',0};...
    'ClutchGain',[1,1],{'gte',0};...
    'lambda_mu',[1,1],{'gt',0};...
    'FrntSuspFOffset',[1,1],{};...
    'FrntSuspMaxComp',[1,1],{'gte',0};...
    'FrntSuspMaxExt',[1,1],{'gte',0};...
    'FrntSuspNatFreq',[1,1],{'gt',0};...
    'FrntSuspDamping',[1,1],{'gte',0};...
    'RearSuspFOffset',[1,1],{};...
    'RearSuspMaxComp',[1,1],{'gte',0};...
    'RearSuspMaxExt',[1,1],{'gte',0};...
    'RearSuspNatFreq',[1,1],{'gt',0};...
    'RearSuspDamping',[1,1],{'gte',0};...

    };

    LookupTblList={{'SpdCrv',{}},'TrqCrv',{};...
    {'SteerVehSpdBpts',{}},'SteerSpdFctTbl',{};...
    {'G',{'int',0}},'N',{};...
    };
    shiftParams=autoblksgetmaskparms(Block,{'G','UpShiftPts','DownShiftPts'},true);

    gearVec=shiftParams{1};

    if~any(shiftParams{1}<0)||~any(shiftParams{1}==0)
        error(message('shared_sim3dblks:sim3dsharederrAutoIcon:gearVectorRandN'));
    end
    if automaticTransType
        sizeUpShiftPts=size(shiftParams{2});
        sizeDownShiftPts=size(shiftParams{3});

        if sizeUpShiftPts(1)>1||sizeUpShiftPts(2)<=1
            error(string(message('shared_sim3dblks:sim3dsharederrAutoIcon:rowVector'))+" UpShiftPts");
        end
        if sizeDownShiftPts(1)>1||sizeDownShiftPts(2)<=1
            error(string(message('shared_sim3dblks:sim3dsharederrAutoIcon:rowVector'))+" DownShiftPts");
        end

        if sizeUpShiftPts(2)~=sizeDownShiftPts(2)
            error(string(message('shared_sim3dblks:sim3dsharederrAutoIcon:equalLengthRowVectors'))+" UpShiftPts and DownShiftPts");
        end

        if any(shiftParams{2}<0)
            error(string(message('shared_sim3dblks:sim3dsharederrAutoIcon:vectorGt0'))+" UpShiftPts");
        end
        if any(shiftParams{3}<0)
            error(string(message('shared_sim3dblks:sim3dsharederrAutoIcon:vectorGt0'))+" DownShiftPts");
        end

        if length(find(gearVec>0))~=sizeUpShiftPts(2)
            error(message('shared_sim3dblks:sim3dsharederrAutoIcon:shiftIndLength2GearLength'));
        end
    end
    MeshPath=MaskObj.getParameter('MeshPath');
    set_param([Block,'/PhysicalVehicle'],'MeshPath',MeshPath.Value);

    if~LightsEnabled
        SwitchPort(Block,'Light controls','Constant','zeros(1,6)');
    else
        SwitchPort(Block,'Light controls','Inport',[]);
    end

    if~HandbrakeEnabled
        SwitchPort(Block,'HndbrkCmd','Constant','0');
    else
        SwitchPort(Block,'HndbrkCmd','Inport',[]);
    end

    if strcmp(get_param(Block,'StandardOutportEnabled'),'on')
        SwitchPort(Block,'Info','Outport',[]);
        SwitchPort(Block,'xdot','Outport',[]);
        SwitchPort(Block,'ydot','Outport',[]);
        SwitchPort(Block,'psi','Outport',[]);
        SwitchPort(Block,'r','Outport',[]);
    else
        SwitchPort(Block,'Info','Terminator',[]);
        SwitchPort(Block,'xdot','Terminator',[]);
        SwitchPort(Block,'ydot','Terminator',[]);
        SwitchPort(Block,'psi','Terminator',[]);
        SwitchPort(Block,'r','Terminator',[]);
    end

    if strcmp(get_param(Block,'TransformOutportEnabled'),'on')
        SwitchPort(Block,'Location','Outport',[]);
        SwitchPort(Block,'Orientation','Outport',[]);
    else
        SwitchPort(Block,'Location','Terminator',[]);
        SwitchPort(Block,'Orientation','Terminator',[]);
    end
    autoblkscheckparams(Block,ParamList,LookupTblList);
    vehType=get_param(BlkHdl,'PassVehMesh');

    switch vehType
    case 'MuscleCar'
        ParamStruct.TrackWidth=1.9;
        ParamStruct.WheelBase=3.02;
        ParamStruct.FrntWhlRadius=0.369;
        ParamStruct.RearWhlRadius=0.369;
    case 'Sedan'
        ParamStruct.TrackWidth=1.9;
        ParamStruct.WheelBase=2.82;
        ParamStruct.FrntWhlRadius=0.350;
        ParamStruct.RearWhlRadius=0.350;
    case 'SportUtilityVehicle'
        ParamStruct.TrackWidth=1.9;
        ParamStruct.WheelBase=2.90;
        ParamStruct.FrntWhlRadius=0.401;
        ParamStruct.RearWhlRadius=0.401;
    case 'SmallPickupTruck'
        ParamStruct.TrackWidth=1.9;
        ParamStruct.WheelBase=3.69;
        ParamStruct.FrntWhlRadius=0.446;
        ParamStruct.RearWhlRadius=0.446;
    case 'Hatchback'
        ParamStruct.TrackWidth=1.9;
        ParamStruct.WheelBase=2.45;
        ParamStruct.FrntWhlRadius=0.306;
        ParamStruct.RearWhlRadius=0.306;
    case 'BoxTruck'
        ParamStruct.TrackWidth=1.38;
        ParamStruct.WheelBase=5.5;
        ParamStruct.FrntWhlRadius=0.5715;
        ParamStruct.RearWhlRadius=0.5715;
    otherwise
        vehParams=autoblksgetmaskparms(Block,{'TrackWidth','WheelBase','FrntWhlRadius','RearWhlRadius'},true);
        ParamStruct.WheelBase=vehParams{2};
        ParamStruct.TrackWidth=vehParams{1};
        ParamStruct.FrntWhlRadius=vehParams{3};
        ParamStruct.RearWhlRadius=vehParams{4};
    end
    debug=0;
    if debug==1
        fprintf('The "%s" has a wheel radius of %0.3g m, a wheelbase of %0.3g m and a track width of %0.3g m.',...
        vehType,ParamStruct.WheelRadius,ParamStruct.WheelBase,ParamStruct.TrackWidth);
    end
end


function HndbrkUpdate(Block,HandbrakeEnabled)
    if HandbrakeEnabled
        autoblksenableparameters(Block,{'FrntWhlHndBrkEnable';'RearWhlHndBrkEnable';'FrntWhlMaxHndBrkTrq';'RearWhlMaxHndBrkTrq'},[],[],[],'false')
    else
        autoblksenableparameters(Block,[],{'FrntWhlHndBrkEnable';'RearWhlHndBrkEnable';'FrntWhlMaxHndBrkTrq';'RearWhlMaxHndBrkTrq'},[],[],'false')
    end
end


function Transcntrl(Block,AutomaticTrans)
    if AutomaticTrans
        autoblksenableparameters(Block,{'UpShiftPts';'tMinShift';'DownShiftPts'},[],[],[],'false')
    else
        autoblksenableparameters(Block,[],{'UpShiftPts';'tMinShift';'DownShiftPts'},[],[],'false')
    end
end


function DrivetrainType(Block,AllWheelDrive)
    if AllWheelDrive
        autoblksenableparameters(Block,{'FrontRearSplit'},[],[],[],'false')
    else
        autoblksenableparameters(Block,[],{'FrontRearSplit'},[],[],'false')
    end
end


function FrntHndbrk(Block,FrontHandbrakeEnabled)
    if FrontHandbrakeEnabled
        autoblksenableparameters(Block,{'FrntWhlMaxHndBrkTrq'},[],[],[],'false')
    else
        autoblksenableparameters(Block,[],{'FrntWhlMaxHndBrkTrq'},[],[],'false')
    end
end


function RearHndbrk(Block,RearHandbrakeEnabled)
    if RearHandbrakeEnabled
        autoblksenableparameters(Block,{'RearWhlMaxHndBrkTrq'},[],[],[],'false')
    else
        autoblksenableparameters(Block,[],{'RearWhlMaxHndBrkTrq'},[],[],'false')
    end
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
        set_param(NewBlkHdl,'Value',Param);
    case 'Terminator'
        autoblksreplaceblock(Block,InportOption,3);
    case 'Outport'
        autoblksreplaceblock(Block,InportOption,4);
    case 'Inport'
        autoblksreplaceblock(Block,InportOption,2);
    case 'Ground'
        autoblksreplaceblock(Block,InportOption,5);
    end
    InportNames={'SteerCmd';'AccelCmd';'DecelCmd';'GearCmd';'HndbrkCmd';'LightStates'};
    OutportNames={'Info';'xdot';'ydot';'psi';'r';'Location';'Orientation'};
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