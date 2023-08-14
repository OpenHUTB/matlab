function[varargout]=autoblksrotdampcplr(varargin)



    block=varargin{1};
    maskMode=varargin{2};


    BlockNames={'Torsional Compliance Coupler';'Torsional Compliance Coupler 2way';...
    'Torsional Compliance Coupler Merge';'Torsional Compliance Coupler 2way Merge'};

    if maskMode==0

        port_config=get_param(block,'port_config');
        cplrMode=get_param(block,'cplrMode');
        switch port_config
        case 'Simulink'
            if strcmp(cplrMode,'Shaft split')
                blkID=1;
            else
                blkID=3;
            end
        case 'Two-way connection'
            if strcmp(cplrMode,'Shaft split')
                blkID=2;
            else
                blkID=4;
            end
        end

        BlockOptions=...
        {['autolibsharedcouplingcommon/',BlockNames{1}],BlockNames{1};...
        ['autolibsharedcouplingcommon/',BlockNames{2}],BlockNames{2};...
        ['autolibsharedcouplingcommon/',BlockNames{3}],BlockNames{3};...
        ['autolibsharedcouplingcommon/',BlockNames{4}],BlockNames{4};...
        };


        autoblksreplaceblock(block,BlockOptions,blkID);


        ParamList={
        'k1',[1,1],{'gte',0};...
        'b1',[1,1],{'gte',0};...
        'theta1_o',[1,1],{'gte',0};...
        'omega1_c',[1,1],{'gt',0};...
        'domega1_o',[1,1],{};...
        'k2',[1,1],{'gte',0};...
        'b2',[1,1],{'gte',0};...
        'theta2_o',[1,1],{'gte',0};...
        'omega2_c',[1,1],{'gt',0};...
        'domega2_o',[1,1],{};...
        };
        LookupTblList={};

        if strcmp(get_param(block,'extInfo'),'on')
            SwitchInport(block,'Info','Outport',[]);
        else
            SwitchInport(block,'Info','Terminator',[]);
        end

        OutNames={'Info'};
        FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport'),'Name');
        [~,PortI]=intersect(OutNames,FoundNames);
        PortI=sort(PortI);
        for i=1:length(PortI)
            set_param([block,'/',OutNames{PortI(i)}],'Port',num2str(i));
        end
        autoblkscheckparams(block,'Torsional Compliance Coupler',ParamList,LookupTblList);

    end
    if maskMode==2
        blkID=get_param(block,'blkID');
        if strcmp(blkID,'0')
            port_config=get_param(block,'port_config');
            if strcmp(port_config,'Simulink')||strcmp(port_config,'Two-way connection')
                autoblksenableparameters(block,{'omega1_c';'omega2_c'});
            else
                autoblksenableparameters(block,[],{'omega1_c';'omega2_c'});
            end
        end
    end
    if maskMode<8
        varargout{1}=[];
    end
    if maskMode==8
        varargout{1}=DrawCommands(block);
    end
end


function IconInfo=DrawCommands(BlkHdl)
    cplrMode=get_param(BlkHdl,'cplrMode');

    AliasNames={'InSpd','InSpd';'Out1Spd','Out1Spd';'Out2Spd','Out2Spd';...
    'InTrq','InTrq';'Out1Trq','Out1Trq';'Out2Trq','Out2Trq';...
    'In1Spd','In1Spd';'In2Spd','In2Spd';'OutSpd','OutSpd';...
    'In1Trq','In1Trq';'In2Trq','In2Trq';'OutTrq','OutTrq';...
    };
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    if strcmp(cplrMode,'Shaft split')
        IconInfo.ImageName='rotdampcplrs.svg';
    else
        IconInfo.ImageName='rotdampcplrm.svg';
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