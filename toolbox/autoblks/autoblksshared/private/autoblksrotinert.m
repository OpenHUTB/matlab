function[varargout]=autoblksrotinert(varargin)



    block=varargin{1};
    maskMode=varargin{2};

    BlockNames={'Rotational Inertia';'Rotational Inertia External Input';'Rotational Inertia 2way';'Rotational Inertia External Input 2way'};

    if maskMode==0

        port_config=get_param(block,'port_config');
        inert_config=get_param(gcb,'externJ');
        switch inert_config
        case 'on'
            switch port_config
            case 'Simulink'
                blkID=2;
            case 'Two-way connection'
                blkID=4;
            end

        case 'off'
            switch port_config
            case 'Simulink'
                blkID=1;
            case 'Two-way connection'
                blkID=3;
            end
        end

        blockSource='autolibsharedcouplingcommon';
        BlockOptions=cell(size(BlockNames,1),2);
        for idx=1:size(BlockNames,1)
            BlockOptions(idx,1:2)={[blockSource,'/',BlockNames{idx}],BlockNames{idx}};
        end

        autoblksreplaceblock(block,BlockOptions,blkID);


        ParamList={
        'J',[1,1],{'gte',0};...
        'b',[1,1],{'gte',0};...
        'omega_o',[1,1],{};...
        };
        LookupTblList={};

        if strcmp(get_param(block,'extInfo'),'on')
            SwitchInport(block,'Info','Outport',[]);
        else
            SwitchInport(block,'Info','Terminator',[]);
        end

        OutNames={'Info','Spd'};
        FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Outport'),'Name');
        [~,PortI]=intersect(OutNames,FoundNames);
        PortI=sort(PortI);
        for i=1:length(PortI)
            set_param([block,'/',OutNames{PortI(i)}],'Port',num2str(i));
        end
        autoblkscheckparams(block,'Rotational Inertia',ParamList,LookupTblList);
    end
    if maskMode==2
        blkID=get_param(block,'blkID');
        if strcmp(blkID,'0')
            port_config=get_param(block,'port_config');
            if strcmp(port_config,'Simulink')||strcmp(port_config,'Two-way connection')
                autoblksenableparameters(block,{'externJ'},[],[],[],1);
            else
                set_param(block,'externJ','off');
                autoblksenableparameters(block,{'J'},{'externJ'},[],[],1);
            end
        end
    end
    if maskMode==3
        blkID=get_param(block,'blkID');
        if strcmp(blkID,'0')
            externJFlag=get_param(block,'externJ');
            if strcmp(externJFlag,'on')
                autoblksenableparameters(block,[],{'J'},[],[],1);
            else
                autoblksenableparameters(block,{'J'},[],[],[],1);
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

    AliasNames={'Spd','Spd';'Inertia','Inertia';...
    'InTrq','InTrq';'OutTrq','OutTrq';...
    };
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='rotdamp.png';
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