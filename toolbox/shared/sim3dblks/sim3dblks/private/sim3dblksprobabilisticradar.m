function[varargout]=sim3dblksprobabilisticradar(varargin)

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
    if bdIsLibrary(bdroot(Block))
        return
    end
    sim3d.utils.internal.SensorCallback.addSensorTag(Block);
    SetSysobjVehicleIdentifier(Block);

    checkSensorParameters(Block);
    SetMountLocation(Block,"Simulation 3D Probabilistic Radar");
end


function SetSysobjVehicleIdentifier(Block)
    mask_object=get_param(Block,"MaskObject");
    vehTag_parameter=mask_object.getParameter("vehTag");
    set_param(sprintf("%s/Simulation 3D Probabilistic Radar",Block),...
    "VehicleIdentifier",vehTag_parameter.Value);
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
    IconInfo.ImageName='sim3dprobradar.png';
    [IconInfo.image,IconInfo.position]=...
    iconImageUpdate(IconInfo.ImageName,1,20,40,'white');
    IconInfo.position(1)=max(0,IconInfo.position(1)-10);
end