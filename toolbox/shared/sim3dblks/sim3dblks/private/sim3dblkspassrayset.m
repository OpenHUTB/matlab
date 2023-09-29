function[varargout]=sim3dblkspassrayset(varargin)
    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'VehExtDistToCenterCallback'
        VehExtDistToCenterCallback(Block);
    case 'TireExtDistToCenterCallback'
        TireExtDistToCenterCallback(Block);
    end
end


function IconInfo=DrawCommands(Block)
    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);
    IconInfo.ImageName='sim3dpassray.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,100,'white');
end


function Initialization(Block)
    SrcSelVeh=get_param(Block,'VehExtEn');
    VehDistToCenterOptions={'sim3dcommon/Vehicle Center Distance Constant Inputs','Vehicle Center Distance Constant Inputs';...
        'sim3dcommon/Vehicle Center Distance External Inputs','Vehicle Center Distance External Inputs'};

    if strcmp(SrcSelVeh,'Constant')
        autoblksreplaceblock(Block,VehDistToCenterOptions,1);
    else
        autoblksreplaceblock(Block,VehDistToCenterOptions,2);
    end
    SrcSelTire=get_param(Block,'TireRadiiExt');
    TireDistToCenterOptions={'sim3dcommon/Tire Center Distance Constant Inputs','Tire Center Distance Constant Inputs';...
        'sim3dcommon/Tire Center Distance External Inputs','Tire Center Distance External Inputs'};

    if strcmp(SrcSelTire,'Constant')
        autoblksreplaceblock(Block,TireDistToCenterOptions,1);
    else
        autoblksreplaceblock(Block,TireDistToCenterOptions,2);
    end

    InportNames={'VehCntr';'TireRadii'};
    FoundNames=get_param(find_system(Block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
    [~,PortI]=intersect(InportNames,FoundNames);
    PortI=sort(PortI);
    for i=1:length(PortI)
        set_param([Block,'/',InportNames{PortI(i)}],'Port',num2str(i));
    end

    ParamList={...
        'VehRayLngth',[1,1],{'gte',0};...
        'LfRayLngth',[1,1],{'gte',0};...
        'RfRayLngth',[1,1],{'gte',0};...
        'LrRayLngth',[1,1],{'gte',0};...
        'RrRayLngth',[1,1],{'gte',0};...
        'VehRayOffset',[1,1],{'gte',-100000;'lte',100000};...
        'LfRayOffset',[1,1],{'gte',-100000;'lte',100000};...
        'RfRayOffset',[1,1],{'gte',-100000;'lte',100000};...
        'LrRayOffset',[1,1],{'gte',-100000;'lte',100000};...
        'RrRayOffset',[1,1],{'gte',-100000;'lte',100000};...
        'VehCntrLngthVal',[1,1],{'gte',0};...
        'TireRadiiVal',[1,1],{'gte',0};...
        'Ts',[1,1],{'st',0};...
    };

    autoblkscheckparams(Block,ParamList);
end


function VehExtDistToCenterCallback(Block)
    SrcSelection=get_param(Block,'VehExtEn');
    DistToCenterSel={'VehCntrLngthVal'};

    if strcmp(SrcSelection,'Constant')
        autoblksenableparameters(Block,DistToCenterSel);
    else
        autoblksenableparameters(Block,[],DistToCenterSel);
    end
end


function TireExtDistToCenterCallback(Block)
    SrcSelection=get_param(Block,'TireRadiiExt');
    DistToCenterSel={'TireRadiiVal'};

    if strcmp(SrcSelection,'Constant')
        autoblksenableparameters(Block,DistToCenterSel);
    else
        autoblksenableparameters(Block,[],DistToCenterSel);
    end
end
