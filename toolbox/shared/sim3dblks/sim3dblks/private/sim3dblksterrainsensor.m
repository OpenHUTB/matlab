function[varargout]=sim3dblksterrainsensor(varargin)

    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};

    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'SetSensorName'
        SetSensorName(Block);
    case 'ConfigureOutputs'
        ConfigureOutputs(Block);
    end
end

function Initialization(Block)

    sim3d.utils.internal.SensorCallback.addSensorTag(Block);




    ParamList={'SampleTime',[1,1],{'st',0};};


    InportNames={'HitLocations','IsValidHit'};

    FoundNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport'),'Name');
    [~,PortI]=intersect(InportNames,FoundNames);
    PortI=sort(PortI);
    for i=1:length(PortI)
        set_param([Block,'/',InportNames{PortI(i)}],'Port',num2str(i));
    end

    checkSensorParameters(Block);
    ConfigureOutputs(Block);
    autoblkscheckparams(Block,ParamList);
end

function ConfigureOutputs(Block)

    infoBus=[Block,'/InfoBus'];
    infoBusHandle=get_param(infoBus,'Handle');
    blockHandle=get_param(Block,'Handle');
    MaskObj=get_param(Block,'MaskObject');
    numWheels=MaskObj.getParameter('NumberOfWheels');
    numWheels=str2double(numWheels.Value);
    set_param(infoBus,'Inputs',num2str(2*numWheels));


    sysObjBlock=get_param([Block,'/Simulation 3D Terrain Sensor'],'Handle');
    sysObjBlockPortHandles=get_param([Block,'/Simulation 3D Terrain Sensor'],'PortHandles');
    sysObjLines=get_param(sysObjBlockPortHandles.Outport,'Line');
    for i=1:length(sysObjLines)
        if(sysObjLines{i}~=-1)
            delete_line(sysObjLines{i});
        end
    end
    delete_line(find_system(blockHandle,'FollowLinks','on','LookUnderMasks','all','FindAll','on','Type','line','Connected','off'))

    signalNames=GenerateSignalNames(numWheels);

    terrainBlockPortHandles=get(sysObjBlock,'PortHandles');
    infoBusPortHandles=get(infoBusHandle,'PortHandles');


    for i=1:size(terrainBlockPortHandles.Outport,2)

        add_line(Block,terrainBlockPortHandles.Outport(i),infoBusPortHandles.Inport(i));
        lineHandle=get_param(terrainBlockPortHandles.Outport(i),'Line');
        set_param(lineHandle,'Name',signalNames{i});
    end
end

function signalNames=GenerateSignalNames(numWheels)
    signalNames=cell(1,2*numWheels);
    for i=1:numWheels
        signalNames{i}=['Wheel',num2str(i),'Positions'];
        signalNames{i+numWheels}=['Wheel',num2str(i),'Status'];
    end
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


    IconInfo.ImageName='sim3dterrainsensor.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
end