function[varargout]=autoblkstransman(varargin)



    block=varargin{1};
    callID=varargin{2};


    varargout{1}={};







    switch callID
    case 0
        Initilization(block)
    case 1
        SubBlkInit(block)
    case 2
        CntrlTypePopupCallback(block);
    case 3
        TransEffModelPopupCallback(block)
    case 4
        varargout{1}=DrawCommands(block);
    case 5
        EtaBlkInit(block)
    end

end


function Initilization(block)


    cntrlType=get_param(block,'cntrlType');
    switch cntrlType
    case 'Ideal integrated controller'
        SwitchInport(block,'CltchCmd',0);
    case 'External control'
        SwitchInport(block,'CltchCmd',1);
    end
    set_param([block,'/Automated Manual Transmission'],'cntrlType',get_param(block,'cntrlType'));


    switch get_param(block,'TransEffModelPopup')
    case 'Gear only'
        SwitchInport(block,'Temp',0)
    case 'Gear, input torque, input speed, and temperature'
        SwitchInport(block,'Temp',1)
    end


    InportNames={'Gear';'CltchCmd';'EngTrq';'DiffTrq';'Temp'};
    NumberInputPorts(block,InportNames)


    ClutchLocked=get_param(block,'ClutchLocked');
    SynchLocked=get_param(block,'SynchLocked');
    set_param([block,'/Automated Manual Transmission'],'ClutchLocked',ClutchLocked);
    set_param([block,'/Automated Manual Transmission'],'SynchLocked',SynchLocked);


    ParamList={'Jin',[1,1],{'gt',0};...
    'bin',[1,1],{'gte',0};...
    'omegain_o',[1,1],{};...
    'omegaout_o',[1,1],{};...
    'G_o',[1,1],{'int',0};...
    'ts',[1,1],{'gt',0};...
    'tc',[1,1],{'gt',0};...
    'maxAbsSpd',[1,1],{'gt',0};...
    'R',[1,1],{'gt',0};...
    'mus',[1,1],{'gt',0};...
    'muk',[1,1],{'gt',0};...
    'K_c',[1,1],{'gte',0}...
    };


    TableList={{'G',{'int',0}},'N',{};...
    {'G',{'int',0}},'Jout',{'gt',0};...
    {'G',{'int',0}},'bout',{'gt',0};...
    {'G',{'int',0}},'eta',{'gt',0;'lte',1};...
    {'Trq_bpts',{},'omega_bpts',{},'G',{'int',0},'Temp_bpts',{'gt',0}},'eta_tbl',{'gt',0;'lte',1}...
    };

    autoblkscheckparams(block,'Automated Manual Transmission',ParamList,TableList);

end


function SubBlkInit(block)

    ParentBlk=[block,'/Simple Clutch Response/Gear, Clutch and Syncro Timing/Syncronizer Timing'];
    CtrlOptions={'autolibdrivetraincommon/Internal Control Clutch Engagement','Internal Control Clutch Engagement';...
    'autolibdrivetraincommon/External Control Clutch Engagement','External Control Clutch Engagement'};

    cntrlType=get_param(block,'cntrlType');
    switch cntrlType
    case 'Ideal integrated controller'
        autoblksreplaceblock(ParentBlk,CtrlOptions,1);
    case 'External control'
        autoblksreplaceblock(ParentBlk,CtrlOptions,2);
    end
end


function CntrlTypePopupCallback(block)
    cntrlType=get_param(block,'cntrlType');
    if strcmp(cntrlType,'Ideal integrated controller')
        autoblksenableparameters(block,{'tc','ClutchLocked'});
    else
        autoblksenableparameters(block,[],{'tc','ClutchLocked'},[],[]);
    end
end


function TransEffModelPopupCallback(block)
    switch get_param(block,'TransEffModelPopup')
    case 'Gear only'
        autoblksenableparameters(block,'eta',{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl'});
    case 'Gear, input torque, input speed, and temperature'
        autoblksenableparameters(block,{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl'},'eta');
    end
end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'InpSpd','InSpd';'InTrq','InTrq';...
    'OutSpd','OutSpd';'OutTrq','OutTrq';...
    'InTrq','InTrq';'OutTrq','OutTrq';...
    };
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='transmission_single_clutch.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,140,'white');
end


function EtaBlkInit(block)

    ParentBlock=block;
    EtaOption={'autolibshareddrivetraincommon/Eta 1D','Eta 1D';...
    'autolibshareddrivetraincommon/Eta 4D','Eta 4D'};
    switch get_param(block,'TransEffModelPopup')
    case 'Gear only'
        autoblksreplaceblock(ParentBlock,EtaOption,1);
        set_param([block,'/',EtaOption{1,2}],'InterpMethod',get_param(block,'InterpMethod'))
    case 'Gear, input torque, input speed, and temperature'
        autoblksreplaceblock(ParentBlock,EtaOption,2);
        set_param([block,'/',EtaOption{2,2}],'InterpMethod',get_param(block,'InterpMethod'))
    end


end


function SwitchInport(Block,PortName,UsePort)

    InportOption={'built-in/Ground',[PortName,' Ground'];...
    'built-in/Inport',PortName};
    if~UsePort
        NewBlkHdl=autoblksreplaceblock(Block,InportOption,1);
        set_param(NewBlkHdl,'ShowName','off');
    else
        autoblksreplaceblock(Block,InportOption,2);
    end

end


function NumberInputPorts(block,InportNames)
    FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
    [~,PortI]=intersect(InportNames,FoundNames);
    PortI=sort(PortI);
    for i=1:length(PortI)
        set_param([block,'/',InportNames{PortI(i)}],'Port',num2str(i));
    end

end