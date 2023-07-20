function[varargout]=autoblksvehdyn1dof(varargin)



    block=varargin{1};
    callID=varargin{2};







    if callID==0



        ParamList={'NF',[1,1],{'gt',0;'int',0};...
        'NR',[1,1],{'gt',0;'int',0};...
        'm',[1,1],{'gt',0};...
        'a',[1,1],{'gte',0};...
        'b',[1,1],{'gte',0};...
        'h',[1,1],{'gte',0};...
        'Cd',[1,1],{'gte',0};...
        'Af',[1,1],{'gte',0};...
        'x_o',[1,1],{};...
        'xdot_o',[1,1],{};...
        'Pabs',[1,1],{'gte',0};...
        'T',[1,1],{'gte',0};...
        'g',[1,1],{'gte',0}};
        autoblkscheckparams(block,'Vehicle Body 1 DOF Longitudinal',ParamList);
        if strcmp(get_param(block,'extTamb'),'on')
            SwitchInport(block,'AirTemp','Inport',[]);
        else
            SwitchInport(block,'AirTemp','Constant','T');
        end
        if strcmp(get_param(block,'extFMode'),'on')
            SwitchInport(block,'FExt','Inport',[]);
        else
            SwitchInport(block,'FExt','Constant','[0,0,0]');
        end
        if strcmp(get_param(block,'extMMode'),'on')
            SwitchInport(block,'MExt','Inport',[]);
        else
            SwitchInport(block,'MExt','Constant','[0,0,0]');
        end
        if strcmp(get_param(block,'wind3D'),'on')
            set_param([block,'/Vehicle Body 1 DOF/WindDim'],'LabelModeActiveChoice','1')
        else
            set_param([block,'/Vehicle Body 1 DOF/WindDim'],'LabelModeActiveChoice','0')
        end



        InportNames={'FExt';'MExt';'FwF';'FwR';'Grade';'WindX';'WindXYZ';'Temp'};
        FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
        [~,PortI]=intersect(InportNames,FoundNames);
        PortI=sort(PortI);
        for i=1:length(PortI)
            set_param([block,'/',InportNames{PortI(i)}],'Port',num2str(i));
            if strcmp(InportNames{PortI(i)},'WindX')&&strcmp(get_param(block,'wind3D'),'on')
                set_param([block,'/',InportNames{PortI(i)}],'Name','WindXYZ')
            elseif strcmp(InportNames{PortI(i)},'WindXYZ')&&strcmp(get_param(block,'wind3D'),'off')
                set_param([block,'/',InportNames{PortI(i)}],'Name','WindX')
            end
        end

        varargout{1}={};
    end
    if callID==2
        if strcmp(get_param(block,'extTamb'),'on')
            autoblksenableparameters(block,[],{'T'},[],[],'true');
        else
            autoblksenableparameters(block,{'T'},[],[],[],'true');
        end
    end
    if callID<4
        varargout{1}={};
    end

    if callID==4
        varargout{1}=DrawCommands(block);
    end
end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'Total Force','Force';'Total Power','Power'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='vehicle_dynamics_1dof.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,70,'white');
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