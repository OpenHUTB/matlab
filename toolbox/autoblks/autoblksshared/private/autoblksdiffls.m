function[varargout]=autoblksdiffls(varargin)


    block=varargin{1};
    callID=varargin{2};
    varargout{1}={};



    switch callID
    case 0
        Initilization(block)
    case 1
        simStatus=get_param(bdroot(block),'SimulationStatus');
        if strcmp(simStatus,'stopped')||strcmp(simStatus,'updating')
            SubBlkInit(block);
        end
    case 2
        TransEffModelPopupCallback(block)
    case 4
        CouplingTypePopupCallback(block)
    case 8
        varargout{1}=DrawCommands(block);
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
    'omegaw1o',[1,1],{'lte',5e3};...
    'omegaw2o',[1,1],{'lte',5e3};...
    'maxAbsSpd',[1,1],{'gt',0};...
    'Reff',[1,1],{'gt',0};...
    'Ndisks',[1,1],{'gt',0;'int',0};...
    'Fc',[1,1],{'gte',0};...
    'tauC',[1,1],{'gt',0};...
    'eta',[1,1],{'gt',0;'lte',1};...
    'Tamb',[1,1],{'gte',0};...
    };
    TableList={{'dw',{}},'muc',{'gte',0};...
    {'dwT',{}},'Tdw',{};...
    {'Tin',{}},'TTin',{};...
    {'Trq_bpts',{},'omega_bpts',{},'Temp_bpts',{'gt',0}},'eta_tbl',{'gt',0;'lte',1}...
    };


    switch get_param(BlkHdl,'DiffEffModelPopup')
    case 'Constant'
        SwitchInport(BlkHdl,'Temp','Ground',[]);
        set_param(BlkHdl,'extTamb','off')
    case 'Driveshaft torque, speed and temperature'
        if strcmp(get_param(BlkHdl,'extTamb'),'on')
            SwitchInport(BlkHdl,'Temp','Inport',[]);
        else
            SwitchInport(BlkHdl,'Temp','Constant','Tamb');

        end
    end
    autoblkscheckparams(BlkHdl,ParamList,TableList);
    if strcmp(get_param(BlkHdl,'DiffEffModelPopup'),'Driveshaft torque, speed and temperature')&&strcmp(get_param(BlkHdl,'extTamb'),'off')
        set_param([BlkHdl,'/TempConstant'],'Value','Tamb');
    end
end

function SubBlkInit(BlkHdl)

    switch get_param(BlkHdl,'DiffEffModelPopup')
    case 'Constant'
        set_param([BlkHdl,'/Efficiency/Eta'],'LabelModeActiveChoice','Constant');
    case 'Driveshaft torque, speed and temperature'
        set_param([BlkHdl,'/Efficiency/Eta'],'LabelModeActiveChoice','3D');
    end
    switch get_param(BlkHdl,'couplingType')
    case 'Pre-loaded ideal clutch'
        if~strcmp(get_param([BlkHdl,'/Coupling Torque'],'LabelModeActiveChoice'),'0')
            set_param([BlkHdl,'/Coupling Torque'],'LabelModeActiveChoice','0');
        end
    case 'Slip speed dependent torque data'
        if~strcmp(get_param([BlkHdl,'/Coupling Torque'],'LabelModeActiveChoice'),'1')
            set_param([BlkHdl,'/Coupling Torque'],'LabelModeActiveChoice','1');
        end
    case 'Input torque dependent torque data'
        if~strcmp(get_param([BlkHdl,'/Coupling Torque'],'LabelModeActiveChoice'),'2')
            set_param([BlkHdl,'/Coupling Torque'],'LabelModeActiveChoice','2');
        end
    end
end

function CouplingTypePopupCallback(BlkHdl)
    switch get_param(BlkHdl,'couplingType')
    case 'Pre-loaded ideal clutch'
        autoblksenableparameters(BlkHdl,[],[],'IdealClutch');
        autoblksenableparameters(BlkHdl,[],[],[],'SlipSpdData');
        autoblksenableparameters(BlkHdl,[],[],[],'InputTrqData');
    case 'Slip speed dependent torque data'
        autoblksenableparameters(BlkHdl,[],[],'SlipSpdData');
        autoblksenableparameters(BlkHdl,[],[],[],'IdealClutch');
        autoblksenableparameters(BlkHdl,[],[],[],'InputTrqData');
    case 'Input torque dependent torque data'
        autoblksenableparameters(BlkHdl,[],[],'InputTrqData');
        autoblksenableparameters(BlkHdl,[],[],[],'IdealClutch');
        autoblksenableparameters(BlkHdl,[],[],[],'SlipSpdData');
    end
end

function TransEffModelPopupCallback(BlkHdl)
    switch get_param(BlkHdl,'DiffEffModelPopup')
    case 'Constant'
        autoblksenableparameters(BlkHdl,'eta',{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl','Tamb','extTamb','InterpMethod'},[],[]);
        set_param([BlkHdl,'/Limited Slip Differential/Efficiency/Eta'],'LabelModeActiveChoice','Constant');
    case 'Driveshaft torque, speed and temperature'
        if strcmp(get_param(BlkHdl,'extTamb'),'on')
            autoblksenableparameters(BlkHdl,{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl','extTamb','InterpMethod',},{'Tamb','eta'},[],[]);
        else
            autoblksenableparameters(BlkHdl,{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl','Tamb','extTamb','InterpMethod'},'eta',[],[]);
        end
        set_param([BlkHdl,'/Limited Slip Differential/Efficiency/Eta'],'LabelModeActiveChoice','3D');
    end
end

function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'DriveshftSpd','DriveshftSpd';...
    'Axl1Trq','Axl1Trq';'Axl2Trq','Axl2Trq';...
    'Axl1Spd','Axl1Spd';'Axl2Spd','Axl2Spd';...
    'DriveshftTrq','DriveshftTrq'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='differential_lsd.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,10,170,'white');
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