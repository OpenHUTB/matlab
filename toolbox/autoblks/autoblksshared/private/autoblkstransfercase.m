function[varargout]=autoblkstransfercase(varargin)



    block=varargin{1};
    callID=varargin{2};
    varargout{1}={};



    switch callID
    case 0
        TransfercaseSetPort(block)
        Initilization(block)
    case 1
        SubBlkInit(block);
    case 2
        TransEffModelPopupCallback(block)
    case 8
        varargout{1}=DrawCommands(block);
    case 10
        TransfercaseInputTrqSplitRatio(block)
    case 11
        TransfercaseInputSpdLock(block)
    end
end


function Initilization(BlkHdl)





    ParamList={'Ndiff',[1,1],{'gt',0};...
    'Jd',[1,1],{'gt',0};...
    'bd',[1,1],{'gte',0};...
    'Jw1',[1,1],{'gt',0};...
    'bw1',[1,1],{'gte',0};...
    'Jw2',[1,1],{'gt',0};...
    'bw2',[1,1],{'gte',0};...
    'eta',[1,1],{'gt',0;'lte',1};...
    'Tamb',[1,1],{'gte',0};...
    'omegaw1o',[1,1],{'lte',5e3};...
    'omegaw2o',[1,1],{'lte',5e3};...
    'maxAbsSpd',[1,1],{'gt',0};...
    'TrqSplitRatio',[1,1],{'gte',0;'lte',1};...
    'SpdLock',[1,1],{'gte',0;'lte',1};...
    };

    TableList={...
    {'Trq_bpts',{},'omega_bpts',{},'Temp_bpts',{'gt',0}},'eta_tbl',{'gt',0;'lte',1}...
    };
    autoblkscheckparams(BlkHdl,ParamList,TableList);

    switch get_param(BlkHdl,'DiffEffModelPopup')
    case 'Constant'
        SwitchInport(BlkHdl,'Temp','Ground',[]);
        set_param(BlkHdl,'extTamb','off')
    case 'Driveshaft torque, speed and temperature'
        if strcmp(get_param(BlkHdl,'extTamb'),'on')
            SwitchInport(BlkHdl,'Temp','Inport',[]);
        else
            SwitchInport(BlkHdl,'Temp','Constant','Tamb');
            set_param([BlkHdl,'/TempConstant'],'Value','Tamb');
        end
    end

end



function SubBlkInit(BlkHdl)

    switch get_param(BlkHdl,'DiffEffModelPopup')
    case 'Constant'
        set_param([BlkHdl,'/Efficiency/Eta'],'LabelModeActiveChoice','Constant');
    case 'Driveshaft torque, speed and temperature'
        set_param([BlkHdl,'/Efficiency/Eta'],'LabelModeActiveChoice','3D');
    end
end

function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'DriveshftSpd','DriveshftSpd';...
    'Axl1Trq','Axl1Trq';'Axl2Trq','Axl2Trq';...
    'Axl1Spd','Axl1Spd';'Axl2Spd','Axl2Spd';...
    'DriveshftTrq','DriveshftTrq'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='transfercase.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,10,90,'white');
end

function TransEffModelPopupCallback(BlkHdl)
    switch get_param(BlkHdl,'DiffEffModelPopup')
    case 'Constant'
        autoblksenableparameters(BlkHdl,'eta',{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl','Tamb','extTamb','InterpMethod'},[],[]);
        set_param([BlkHdl,'/Efficiency/Eta'],'LabelModeActiveChoice','Constant');
    case 'Driveshaft torque, speed and temperature'
        if strcmp(get_param(BlkHdl,'extTamb'),'on')
            autoblksenableparameters(BlkHdl,{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl','extTamb','InterpMethod',},{'Tamb','eta'},[],[]);
        else
            autoblksenableparameters(BlkHdl,{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl','Tamb','extTamb','InterpMethod'},'eta',[],[]);
        end
        set_param([BlkHdl,'/Efficiency/Eta'],'LabelModeActiveChoice','3D');
    end
end

function SwitchInport(Block,PortName,UsePort,Param)

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
end

function SwitchBlock(Block,PortName,UsePort,Param)

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
end

function TransfercaseSetPort(block)
    checkbox1=get_param(block,'TrqSplitRatioMode');
    checkbox2=get_param(block,'SpdLockMode');
    if strcmp(checkbox1,'on')
        autoblksenableparameters(block,[],{'TrqSplitRatio'},[],[],1);
        SwitchInport(block,'TrqSplitRatioConstant','Inport','TrqSplitRatio');
    else
        autoblksenableparameters(block,{'TrqSplitRatio'},[],[],[],1);
        SwitchInport(block,'TrqSplitRatioConstant','Constant','TrqSplitRatio');
    end
    if strcmp(checkbox2,'on')
        autoblksenableparameters(block,[],{'SpdLock'},[],[],1);
        SwitchInport(block,'SpdLockConstant','Inport','SpdLock');
    else
        autoblksenableparameters(block,{'SpdLock'},[],[],[],1);
        SwitchInport(block,'SpdLockConstant','Constant','SpdLock');
    end

end

function TransfercaseInputTrqSplitRatio(block)
    if strcmp(get_param(block,'TrqSplitRatioMode'),'on')
        autoblksenableparameters(block,[],{'TrqSplitRatio'},[],[],'true');
    else
        autoblksenableparameters(block,{'TrqSplitRatio'},[],[],[],'true');
    end
end

function TransfercaseInputSpdLock(block)
    if strcmp(get_param(block,'SpdLockMode'),'on')
        autoblksenableparameters(block,[],{'SpdLock'},[],[],'true');
    else
        autoblksenableparameters(block,{'SpdLock'},[],[],[],'true');
    end
end
