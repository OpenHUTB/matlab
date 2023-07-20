function[varargout]=autoblksrotdamp(varargin)



    block=varargin{1};
    maskMode=varargin{2};



    BlockNames={'Torsional Compliance Linear';'Torsional Compliance Linear 2way'};

    if maskMode==0

        port_config=get_param(block,'port_config');
        switch port_config
        case 'Simulink'
            blkID=1;
        case 'Two-way connection'
            blkID=2;
        end

        BlockOptions=...
        {['autolibsharedcouplingcommon/',BlockNames{1}],BlockNames{1};...
        ['autolibsharedcouplingcommon/',BlockNames{2}],BlockNames{2};...
        };


        autoblksreplaceblock(block,BlockOptions,blkID);


        ParamList={
        'k',[1,1],{'gte',0};...
        'b',[1,1],{'gte',0};...
        'theta_o',[1,1],{'gte',0};...
        'omega_c',[1,1],{'gt',0};...
        'domega_o',[1,1],{};...
        };
        LookupTblList={};

        if strcmp(get_param(block,'extInfo'),'on')
            SwitchInport(block,'Info','Outport',[]);
        else
            SwitchInport(block,'Info','Terminator',[]);
        end

        OutNames={'Info','RTrq','CTrq'};
        FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport'),'Name');
        [~,PortI]=intersect(OutNames,FoundNames);
        PortI=sort(PortI);
        for i=1:length(PortI)
            set_param([block,'/',OutNames{PortI(i)}],'Port',num2str(i));
        end
        autoblkscheckparams(block,'Torsional Compliance',ParamList,LookupTblList);
    end
    if maskMode==2
        blkID=get_param(block,'blkID');
        if strcmp(blkID,'0')
            port_config=get_param(block,'port_config');
            if strcmp(port_config,'Simulink')||strcmp(port_config,'Two-way connection')
                autoblksenableparameters(block,{'omega_c'});
            else
                autoblksenableparameters(block,[],{'omega_c'});
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

    AliasNames={'InSpd','InSpd';'OutSpd','OutSpd';...
    'InTrq','InTrq';'OutTrq','OutTrq';...
    };
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='rotdampcplschem.png';
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