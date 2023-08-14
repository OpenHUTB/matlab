function[varargout]=vehdyn6doftrailer(varargin)



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


            if strcmp(get_param(block,'htchFMode_f'),'on')
                SwitchInport(block,'FhF','Inport',[]);
            else
                SwitchInport(block,'FhF','Ground');
            end

            if strcmp(get_param(block,'htchMMode_f'),'on')
                SwitchInport(block,'MhF','Inport',[]);
            else
                SwitchInport(block,'MhF','Ground');
            end


            if strcmp(get_param(block,'htchFMode_r'),'on')
                SwitchInport(block,'FhR','Inport',[]);
            else
                SwitchInport(block,'FhR','Ground');
            end

            if strcmp(get_param(block,'htchMMode_r'),'on')
                SwitchInport(block,'MhR','Inport',[]);
            else
                SwitchInport(block,'MhR','Ground');
            end


            if strcmp(get_param(block,'axleMode'),'2')
                set_param([block,'/Moment Calc'],'LabelModeActiveChoice','1');
                set_param([block,'/Middle Axle Parameters'],'LabelModeActiveChoice','0');
                set_param([block,'/Signal Routing'],'LabelModeActiveChoice','1');
                set_param([block,'/Forces'],'LabelModeActiveChoice','1');
                set_param([block,'/Susp2Chassis'],'LabelModeActiveChoice','1');
                set_param([block,'/6 DOF Generic Vehicle Body/Aero Drag'],'LabelModeActiveChoice','TwoAxleTrailer');
            elseif strcmp(get_param(block,'axleMode'),'3')
                set_param([block,'/Moment Calc'],'LabelModeActiveChoice','2');
                set_param([block,'/Middle Axle Parameters'],'LabelModeActiveChoice','1');
                set_param([block,'/Signal Routing'],'LabelModeActiveChoice','2');
                set_param([block,'/Forces'],'LabelModeActiveChoice','2');
                set_param([block,'/Susp2Chassis'],'LabelModeActiveChoice','2');
                set_param([block,'/6 DOF Generic Vehicle Body/Aero Drag'],'LabelModeActiveChoice','ThreeAxleTrailer');
            else
                set_param([block,'/Moment Calc'],'LabelModeActiveChoice','0');
                set_param([block,'/Middle Axle Parameters'],'LabelModeActiveChoice','2');
                set_param([block,'/Signal Routing'],'LabelModeActiveChoice','0');
                set_param([block,'/Forces'],'LabelModeActiveChoice','0');
                set_param([block,'/Susp2Chassis'],'LabelModeActiveChoice','0');
                set_param([block,'/6 DOF Generic Vehicle Body/Aero Drag'],'LabelModeActiveChoice','OneAxleTrailer');
            end

            if strcmp(get_param(block,'htchFMode_f'),'on')||strcmp(get_param(block,'htchMMode_f'),'on')
                if strcmp(get_param(block,'axleMode'),'2')
                    set_param([block,'/Moment Calc/Moment Calc 2 Axles/Front hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','1');
                elseif strcmp(get_param(block,'axleMode'),'3')
                    set_param([block,'/Moment Calc/Moment Calc 3 Axles/Front hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','1');
                else
                    set_param([block,'/Moment Calc/Moment Calc 1 Axle/Front hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','1');
                end
            else
                if strcmp(get_param(block,'axleMode'),'2')
                    set_param([block,'/Moment Calc/Moment Calc 2 Axles/Front hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','0');
                elseif strcmp(get_param(block,'axleMode'),'3')
                    set_param([block,'/Moment Calc/Moment Calc 3 Axles/Front hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','0');
                else
                    set_param([block,'/Moment Calc/Moment Calc 1 Axle/Front hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','0');
                end
            end

            if strcmp(get_param(block,'htchFMode_r'),'on')||strcmp(get_param(block,'htchMMode_r'),'on')
                if strcmp(get_param(block,'axleMode'),'2')
                    set_param([block,'/Moment Calc/Moment Calc 2 Axles/Rear hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','1');
                elseif strcmp(get_param(block,'axleMode'),'3')
                    set_param([block,'/Moment Calc/Moment Calc 3 Axles/Rear hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','1');
                else
                    set_param([block,'/Moment Calc/Moment Calc 1 Axle/Rear hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','1');
                end
            else
                if strcmp(get_param(block,'axleMode'),'2')
                    set_param([block,'/Moment Calc/Moment Calc 2 Axles/Rear hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','0');
                elseif strcmp(get_param(block,'axleMode'),'3')
                    set_param([block,'/Moment Calc/Moment Calc 3 Axles/Rear hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','0');
                else
                    set_param([block,'/Moment Calc/Moment Calc 1 Axle/Rear hitch moments from forces/hitch geometry parameters'],'LabelModeActiveChoice','0');
                end
            end


            InportNames={'FSusp';'MSusp';'FExt';'MExt';'FhF';'MhF';'FhR';'MhR';'WindXYZ';'AirTemp'};
            FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
            [~,PortI]=intersect(InportNames,FoundNames);
            PortI=sort(PortI);
            for i=1:length(PortI)
                set_param([block,'/',InportNames{PortI(i)}],'Port',num2str(i));
            end

        end

        ParamList={...
        'm',[1,1],{'gt',0};...
        'a',[1,1],{};...
        'd',[1,1],{};...
        'h',[1,1],{'gte',0};...
        'w_f',[1,1],{'gte',0};...
        'Xe_o',[1,3],{};...
        'xbdot_o',[1,3],{};...
        'eul_o',[1,3],{};...
        'p_o',[1,3],{};...
        'Iveh',[3,3],{};...
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

        if strcmp(get_param(block,'htchFMode_f'),'on')||strcmp(get_param(block,'htchMMode_f'),'on')

            FHitchParmList={'hl_f',[1,1],{};...
            'hh_f',[1,1],{'gte',0};...
            'dh_f',[1,1],{'gte',0}};

        else

            FHitchParmList={};

        end

        if strcmp(get_param(block,'htchFMode_r'),'on')||strcmp(get_param(block,'htchMMode_r'),'on')

            RHitchParmList={'hl_r',[1,1],{};...
            'hh_r',[1,1],{'gte',0};...
            'dh_r',[1,1],{'gte',0}};

        else

            RHitchParmList={};

        end


        if strcmp(get_param(block,'axleMode'),'2')
            AxleParmList={'c',[1,1],{};...
            'w_r',[1,1],{'gte',0}};
        elseif strcmp(get_param(block,'axleMode'),'3')
            AxleParmList={'b',[1,1],{};...
            'c',[1,1],{};...
            'w_m',[1,1],{'gte',0};...
            'w_r',[1,1],{'gte',0};...
            };
        else
            AxleParmList={};
        end


        LookupTblList={{'beta_w',{}},'Cs',{};...
        {'beta_w',{}},'Cym',{}};
        autoblkscheckparams(block,'Trailer Body 6DOF',[ParamList;AxleParmList;FHitchParmList;RHitchParmList],LookupTblList);
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

    case 3

        if strcmp(get_param(block,'axleMode'),'2')
            autoblksenableparameters(block,{'c','w_r'},{'b','w_m'},[],[]);
        elseif strcmp(get_param(block,'axleMode'),'3')
            autoblksenableparameters(block,{'b','w_m','c','w_r'},{},[],[]);
        else
            autoblksenableparameters(block,{},{'b','w_m','c','w_r'},[],[]);
        end

        varargout{1}=0;

    case 4

        if strcmp(get_param(block,'htchFMode_f'),'on')||strcmp(get_param(block,'htchMMode_f'),'on')
            autoblksenableparameters(block,{'dh_f';'hh_f';'hl_f'},{},[],[]);
        else
            autoblksenableparameters(block,{},{'dh_f';'hh_f';'hl_f'},[],[]);
        end

        if strcmp(get_param(block,'htchFMode_r'),'on')||strcmp(get_param(block,'htchMMode_r'),'on')
            autoblksenableparameters(block,{'dh_r';'hh_r';'hl_r'},{},[],[]);
        else
            autoblksenableparameters(block,{},{'dh_r';'hh_r';'hl_r'},[],[]);
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

    axleMode=get_param(BlkHdl,'axleMode');

    if strcmp(axleMode,'2')
        IconInfo.ImageName='6dof2axletrailer.png';
    elseif strcmp(axleMode,'3')
        IconInfo.ImageName='6dof3axletrailer.png';
    else
        IconInfo.ImageName='6dof1axletrailer.png';
    end

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