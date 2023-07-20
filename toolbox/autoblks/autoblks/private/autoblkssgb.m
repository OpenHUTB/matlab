function[varargout]=autoblkssgb(varargin)


    block=varargin{1};
    callID=varargin{2};
    varargout{1}={};




    switch callID
    case 0
        Initilization(block);





    case 2
        TransEffModelPopupCallback(block)
    case 8
        varargout{1}=DrawCommands(block);
    end

end


function Initilization(BlkHdl)
    [BlockOptions,blkID]=getBlockType(BlkHdl);
    if strcmp(get_param(BlkHdl,'blkID'),'0')
        TransEffModelPopupCallback(BlkHdl);
    end
    autoblksreplaceblock(BlkHdl,BlockOptions,blkID);

    switch get_param(BlkHdl,'DiffEffModelPopup')
    case 'Constant'
        SwitchInport(BlkHdl,'Temp','Ground',[]);
        set_param(BlkHdl,'extTamb','off')
    case 'Driveshaft torque, speed and temperature'
        if strcmp(get_param(BlkHdl,'extTamb'),'on')
            SwitchInport(BlkHdl,'Temp','Inport',[]);
        else
            SwitchInport(BlkHdl,'Temp','Constant','0');
            set_param([BlkHdl,'/TempConstant'],'Value','0');
        end
    end

    simStopped=true;
    TableList={...
    {'Trq_bpts',{},'omega_bpts',{},'Temp_bpts',{'gt',0}},'eta_tbl',{'gt',0;'lte',1}...
    };
    autoblkscheckparams(BlkHdl,[],TableList);
    if simStopped
        effType=get_param(BlkHdl,'DiffEffModelPopup');
        interpType=get_param(BlkHdl,'InterpMethod');
        switch effType
        case 'Constant'
            autoblksenableparameters(BlkHdl,'eta',{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl','Tamb','extTamb','InterpMethod'},[],[]);
            if blkID==1
                set_param([BlkHdl,'/',BlockOptions{blkID,2},'/Efficiency/Eta'],'LabelModeActiveChoice','Constant');
                set_param([BlkHdl,'/',BlockOptions{blkID,2}],'DiffEffModelPopup',effType);
                set_param([BlkHdl,'/',BlockOptions{blkID,2}],'InterpMethod',interpType);
            else
                set_param([BlkHdl,'/',BlockOptions{blkID,2},'/Ideal Gear Tin/Efficiency/Eta'],'LabelModeActiveChoice','Constant');


            end
        case 'Driveshaft torque, speed and temperature'
            if blkID==1
                set_param([BlkHdl,'/',BlockOptions{blkID,2},'/Efficiency/Eta'],'LabelModeActiveChoice','3D');
                set_param([BlkHdl,'/',BlockOptions{blkID,2}],'DiffEffModelPopup',effType);
                set_param([BlkHdl,'/',BlockOptions{blkID,2}],'InterpMethod',interpType);
            else
                set_param([BlkHdl,'/',BlockOptions{blkID,2},'/Ideal Gear Tin/Efficiency/Eta'],'LabelModeActiveChoice','3D');


            end
            if strcmp(get_param(BlkHdl,'extTamb'),'on')
                autoblksenableparameters(BlkHdl,{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl','extTamb','InterpMethod',},{'Tamb','eta'},[],[]);
            else
                autoblksenableparameters(BlkHdl,{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl','Tamb','extTamb','InterpMethod'},'eta',[],[]);
            end
        end



    end







    ParamList={'N',[1,1],{'gt',0};...
    'J1',[1,1],{'gt',0};...
    'J2',[1,1],{'gt',0};...
    'b1',[1,1],{'gte',0};...
    'b2',[1,1],{'gte',0};...
    'theta1_o',[1,1],{};...
    'w1_o',[1,1],{};...
    'eta',[1,1],{'gt',0;'lte',1};...
    'Tamb',[1,1],{'gte',0};...
    };
    TableList={...
    {'Trq_bpts',{},'omega_bpts',{},'Temp_bpts',{'gt',0}},'eta_tbl',{'gt',0;'lte',1}...
    };
    autoblkscheckparams(BlkHdl,ParamList,TableList);



    gearDir=get_param(BlkHdl,'dirSwitch');
    set_param([BlkHdl,'/',BlockOptions{blkID,2}],'dirSwitch',gearDir);
    if strcmp(get_param(BlkHdl,'DiffEffModelPopup'),'Driveshaft torque, speed and temperature')&&strcmp(get_param(BlkHdl,'extTamb'),'off')
        set_param([BlkHdl,'/TempConstant'],'Value','Tamb');
    end


end













function TransEffModelPopupCallback(BlkHdl)

    effType=get_param(BlkHdl,'DiffEffModelPopup');
    switch effType
    case 'Constant'
        autoblksenableparameters(BlkHdl,'eta',{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl','Tamb','extTamb','InterpMethod'},[],[]);
    case 'Driveshaft torque, speed and temperature'
        if strcmp(get_param(BlkHdl,'extTamb'),'on')
            autoblksenableparameters(BlkHdl,{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl','extTamb','InterpMethod',},{'Tamb','eta'},[],[]);
        else
            autoblksenableparameters(BlkHdl,{'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl','Tamb','extTamb','InterpMethod'},'eta',[],[]);
        end
    end

end

function IconInfo=DrawCommands(BlkHdl)
    port_config=get_param(BlkHdl,'port_config');
    switch port_config
    case 'Simulink'

        AliasNames={'w1','BSpd';'w2','FSpd';...
        'T1','BTrq';'T2','FTrq';...
        'Info','Info'};
    case 'Two-way connection'
        AliasNames={'Info','Info';...
        'B','B';'F','F'};
    end
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

    IconInfo.ImageName='ideal_gear.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,10,90,'white');
end

function[BlockOptions,blkID]=getBlockType(BlkHdl)
    BlockNames={'Ideal Gear Tin';'Ideal Gear win';...
    'Ideal Gear Tin 2way';'Ideal Gear win 2way'};
    BlockOptions=cell(length(BlockNames),2);

    for idx=1:length(BlockNames)
        BlockOptions(idx,:)={['autolibdrivetraincommon/',BlockNames{idx}],BlockNames{idx}};
    end
    port_config=get_param(BlkHdl,'port_config');
    input_config=get_param(BlkHdl,'input_config');
    switch port_config
    case 'Simulink'
        switch input_config
        case 'Torque input - velocity output'
            blkID=1;
        case 'Velocity input - torque output'
            blkID=2;
        end
    case 'Two-way connection'
        switch input_config
        case 'Torque input - velocity output'
            blkID=3;
        case 'Velocity input - torque output'
            blkID=4;
        end
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