function[varargout]=vehdyn6dofcar(varargin)



    block=varargin{1};
    maskMode=varargin{2};

    simStopped=autoblkschecksimstopped(block);




    switch maskMode
    case 0
        if simStopped
            if strcmp(get_param(block,'extTamb'),'on')
                SwitchInport(block,'AirTemp','Inport',[]);
            else
                SwitchInport(block,'AirTemp','Constant','273');
            end

            if strcmp(get_param(block,'wrapAng'),'off')
                set_param([block,'/6 DOF Generic Vehicle Body/SignalCollection/Angle Wrap'],'LabelModeActiveChoice','Unwrap')
            else
                set_param([block,'/6 DOF Generic Vehicle Body/SignalCollection/Angle Wrap'],'LabelModeActiveChoice','None')
            end

            if strcmp(get_param(block,'htchFMode'),'on')
                SwitchInport(block,'Fh','Inport',[]);
            else
                SwitchInport(block,'Fh','Ground');
            end

            if strcmp(get_param(block,'htchMMode'),'on')
                SwitchInport(block,'Mh','Inport',[]);
            else
                SwitchInport(block,'Mh','Ground');
            end

            if strcmp(get_param(block,'htchFMode'),'on')||strcmp(get_param(block,'htchMMode'),'on')
                set_param([block,'/Moment Calc/Hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','1');
            else
                set_param([block,'/Moment Calc/Hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','0');
            end


            InportNames={'FSusp';'MSusp';'FExt';'MExt';'Fh';'Mh';'WindXYZ';'AirTemp'};
            FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
            [~,PortI]=intersect(InportNames,FoundNames);
            PortI=sort(PortI);
            for i=1:length(PortI)
                set_param([block,'/',InportNames{PortI(i)}],'Port',num2str(i));
            end

        end

        ParamList={...
        'm',[1,1],{'gt',0};...
        'a',[1,1],{'gte',0};...
        'b',[1,1],{'gte',0};...
        'd',[1,1],{};...
        'h',[1,1],{'gte',0};...
        'Xe_o',[1,3],{};...
        'xbdot_o',[1,3],{};...
        'eul_o',[1,3],{};...
        'p_o',[1,3],{};...
        'Iveh',[3,3],{};...
        'w',[1,2],{'gte',0};...
        'Af',[1,1],{'gte',0};...
        'Cd',[1,1],{'gte',0};...
        'Cl',[1,1],{};...
        'Cpm',[1,1],{};...
        'Pabs',[1,1],{'gte',0};...
        'Tair',[1,1],{'gt',0};...
        'g',[1,1],{};...
        'z1m',[1,1],{'gte',0};...
        'z1R',[1,3],{};...
        'z1I',[3,3],{};...
        'z2m',[1,1],{'gte',0};...
        'z2R',[1,3],{};...
        'z2I',[3,3],{};...
        'z3m',[1,1],{'gte',0};...
        'z3R',[1,3],{};...
        'z3I',[3,3],{};...
        'z4m',[1,1],{'gte',0};...
        'z4R',[1,3],{};...
        'z4I',[3,3],{};...
        'z5m',[1,1],{'gte',0};...
        'z5R',[1,3],{};...
        'z5I',[3,3],{};...
        'z6m',[1,1],{'gte',0};...
        'z6R',[1,3],{};...
        'z6I',[3,3],{};...
        'z7m',[1,1],{'gte',0};...
        'z7R',[1,3],{};...
        'z7I',[3,3],{};...
        };

        if strcmp(get_param(block,'htchFMode'),'on')||strcmp(get_param(block,'htchMMode'),'on')

            HitchParmList={'hl',[1,1],{};...
            'hh',[1,1],{'gte',0};...
            'dh',[1,1],{'gte',0}
            };
            if autoblkschecksimstopped(block)
                autoblksenableparameters(block,{'dh';'hh';'hl'},{},[],[]);
            end

        else
            HitchParmList={};
            if autoblkschecksimstopped(block)
                autoblksenableparameters(block,{},{'dh';'hh';'hl'},[],[]);
            end
        end

        LookupTblList={{'beta_w',{}},'Cs',{};...
        {'beta_w',{}},'Cym',{}};
        autoblkscheckparams(block,'Vehicle Body 6DOF',[ParamList;HitchParmList],LookupTblList);
        if~strcmp(get_param(block,'extTamb'),'on')
            set_param([block,'/AirTempConstant'],'Value','Tair');
        end
        varargout{1}=0;

    case 1

        varargout{1}=0;
    case 2
        if strcmp(get_param(block,'extTamb'),'on')
            autoblksenableparameters(block,[],{'Tair'},[],[],'true');
        else
            autoblksenableparameters(block,{'Tair'},[],[],[],'true');
        end
        varargout{1}=0;

    case 8
        varargout{1}=DrawCommands(block);

    otherwise
        varargout{1}=0;
    end
end
function IconInfo=DrawCommands(BlkHdl)


    AliasNames={'Ff','Ff';...
    'Info','Info'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

    IconInfo.ImageName='6dofcar.png';

    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,10,30,'white');
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