function[varargout]=autoblkstransidealfixed(varargin)



    block=varargin{1};
    callID=varargin{2};
    varargout{1}={};




    switch callID
    case 0
        Initilization(block)
    case 1
        SubBlkInit(block)
    case 2
        TransEffModelPopupCallback(block)
    case 4
        varargout{1}=DrawCommands(block);
    end
end


function Initilization(block)


    autoblkstransidealfixed(block,2);


    effMode=get_param(block,'TransEffModelPopup');
    switch effMode
    case 'Gear only'
        SwitchInport(block,'Temp',0)
        set_param([block,'/Ideal Fixed Gear Transmission/Locked/gear2props'],'lookupType','1D');
        set_param([block,'/Ideal Fixed Gear Transmission/Unlocked/gear2props'],'lookupType','1D');
    case 'Gear, input torque, input speed, and temperature'
        SwitchInport(block,'Temp',1)
        set_param([block,'/Ideal Fixed Gear Transmission/Locked/gear2props'],'lookupType','4D');
        set_param([block,'/Ideal Fixed Gear Transmission/Unlocked/gear2props'],'lookupType','4D');
    end


    ParamList={'omega_o',[1,1],{};...
    'tau_s',[1,1],{'gt',0};...
    'maxAbsSpd',[1,1],{'gt',0};...
    'omegaN_o',[1,1],{};...
    'G_o',[1,1],{'int',0}...
    };

    TableList={{'G',{'int',0}},'N',{};...
    {'G',{'int',0}},'Jout',{'gt',0};...
    {'G',{'int',0}},'bout',{'gt',0};...
    {'G',{'int',0}},'eta',{'gt',0;'lte',1};...
    {'Trq_bpts',{},'omega_bpts',{},'G',{'int',0},'Temp_bpts',{'gt',0}},'eta_tbl',{'gt',0;'lte',1}...
    };
    ParamStruct=autoblkscheckparams(block,ParamList,TableList);
    Nindx=find(ParamStruct.G==0);
    if ParamStruct.Jout(Nindx+1)-ParamStruct.Jout(Nindx)<=0
        error(message('autoblks_shared:autoerrFixedGearTrans:invalidInertia'));
    end


end

function SubBlkInit(block)
    simStopped=autoblkschecksimstopped(block,true);
    if simStopped

        ParentBlock1=[block,'/Ideal Fixed Gear Transmission/Locked/gear2props'];
        ParentBlock2=[block,'/Ideal Fixed Gear Transmission/Unlocked/gear2props'];
        switch get_param(block,'TransEffModelPopup')
        case 'Gear only'
            set_param(ParentBlock1,'lookupType','1D');
            set_param(ParentBlock2,'lookupType','1D');
        case 'Gear, input torque, input speed, and temperature'
            set_param(ParentBlock1,'lookupType','4D');
            set_param(ParentBlock2,'lookupType','4D');
        end
    end
end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'InSpd','InSpd';'InTrq','InTrq';...
    'OutSpd','OutSpd';'OutTrq','OutTrq';...
    'InTrq','InTrq';'OutTrq','OutTrq';...
    };
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='transmission_fixed_gear.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,140,'white');
end


function TransEffModelPopupCallback(block)
    switch get_param(block,'TransEffModelPopup')
    case 'Gear only'
        autoblksenableparameters(block,'eta',{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl'});
    case 'Gear, input torque, input speed, and temperature'
        autoblksenableparameters(block,{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl'},'eta');
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