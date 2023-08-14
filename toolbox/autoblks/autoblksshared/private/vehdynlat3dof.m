function[varargout]=vehdynlat3dof(varargin)


    block=varargin{1};
    maskMode=varargin{2};
    maskObj=Simulink.Mask.get(block);
    inputMode=get_param(block,'inputMode');
    FznomObj=maskObj.getParameter('Fznom');
    trackMode=get_param(block,'trackMode');
    modelname=bdroot(block);
    simMode=get_param(modelname,'SimulationStatus');
    if strcmp(simMode,'running')||strcmp(simMode,'paused')||strcmp(simMode,'compiled')||strcmp(simMode,'restarting')
        simStopped=false;
    else
        simStopped=true;
    end









    switch maskMode
    case 0
        checkboxList={'extTamb';'extXo';'extxdoto';'extYo';'extydoto';'extpsio';'extro';'muMode'};
        paramList={'Tair';'X_o';'xdot_o';'Y_o';'ydot_o';'psi_o';'r_o'};
        labelList={'AirTemp';'X_o';'xdot_o';'Y_o';'ydot_o';'psi_o';'r_o'};
        if simStopped
            [~]=vehdynlat3dof(block,7);
            switch inputMode
            case 'External longitudinal velocity'
                if strcmp(get_param(block,'extxdoto'),'on')
                    warning(message('autoblks_shared:autosharederr3DOFLat:invalidextxdoto'));
                    set_param(block,'extxdoto','off');
                end
                SwitchInport(block,'xdotin',true)
                set_param([block,'/state'],'LabelModeActiveChoice','1');
                if strcmp(trackMode,'Single (bicycle)')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/Signal Routing/Signal Routing/Power/xdot mode'],'LabelModeActiveChoice','0');
                else
                    set_param([block,'/front forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/Signal Routing/Signal Routing Dual/Power/xdot mode'],'LabelModeActiveChoice','0');
                end
                SwitchInport(block,'FwF',false);
                SwitchInport(block,'FwR',false);
            case 'External longitudinal forces'
                SwitchInport(block,'xdotin',false)
                set_param([block,'/state'],'LabelModeActiveChoice','0');
                if strcmp(trackMode,'Single (bicycle)')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','1');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','1');
                    set_param([block,'/Signal Routing/Signal Routing/Power/xdot mode'],'LabelModeActiveChoice','1');
                else
                    set_param([block,'/front forces'],'LabelModeActiveChoice','4');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','4');
                    set_param([block,'/Signal Routing/Signal Routing Dual/Power/xdot mode'],'LabelModeActiveChoice','1');
                end
                SwitchInport(block,'FwF',true);
                SwitchInport(block,'FwR',true);
            case 'External forces'
                SwitchInport(block,'xdotin',false)
                set_param([block,'/state'],'LabelModeActiveChoice','0');
                if strcmp(get_param(block,'muMode'),'on')
                    warning(message('autoblks_shared:autosharederr3DOFLat:invalidmuMode'));
                    set_param(block,'muMode','off');
                end
                if strcmp(trackMode,'Single (bicycle)')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','2');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','2');
                    set_param([block,'/Signal Routing/Signal Routing/Power/xdot mode'],'LabelModeActiveChoice','1');
                else
                    set_param([block,'/front forces'],'LabelModeActiveChoice','5');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','5');
                    set_param([block,'/Signal Routing/Signal Routing Dual/Power/xdot mode'],'LabelModeActiveChoice','1');
                end
                SwitchInport(block,'FwF',true);
                SwitchInport(block,'FwR',true);
            otherwise

            end

            CalphaMode=get_param(block,'CalphaMode');
            switch CalphaMode
            case 'on'

                if strcmp(trackMode,'Single (bicycle)')
                    set_param([block,'/Cy'],'LabelModeActiveChoice','1');
                else
                    set_param([block,'/Cy'],'LabelModeActiveChoice','3');
                end
            otherwise
                if strcmp(trackMode,'Single (bicycle)')
                    set_param([block,'/Cy'],'LabelModeActiveChoice','0');
                else
                    set_param([block,'/Cy'],'LabelModeActiveChoice','2');
                end
            end

            optList={'frontSteerMode';'rearSteerMode';'windMode';'muMode';'extFMode';'extMMode';'htchFMode';'htchMMode'};
            varList={'front steer';'rear steer';'wind';'friction';'noVariant';'noVariant';'noVariant';'noVariant'};
            InportNames={'WhlAngF';'WhlAngR';'WindXYZ';'Mu';'FExt';'MExt';'Fh';'Mh'};
            if strcmp(get_param(block,'htchFMode'),'on')||strcmp(get_param(block,'htchMMode'),'on')
                if strcmp(trackMode,'Single (bicycle)')
                    set_param([block,'/hitch geometry parameters'],'LabelModeActiveChoice','1');
                else
                    set_param([block,'/hitch geometry parameters'],'LabelModeActiveChoice','2');
                end
            else
                set_param([block,'/hitch geometry parameters'],'LabelModeActiveChoice','3');
            end
            for idx=1:length(optList)
                if strcmp(get_param(block,optList{idx}),'on')
                    SwitchInport(block,InportNames{idx},true)
                    if~(strcmp(varList{idx},'noVariant'))
                        if strcmp(trackMode,'Single (bicycle)')||strcmp(varList{idx},'wind')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','1');
                        else
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','3');
                        end
                    end
                else
                    SwitchInport(block,InportNames{idx},false)
                    if~(strcmp(varList{idx},'noVariant'))
                        if strcmp(trackMode,'Single (bicycle)')||strcmp(varList{idx},'wind')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','0');
                        else
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','2');
                        end
                    end
                end
            end
            sigmaMode=get_param(block,'sigmaMode');
            if strcmp(inputMode,'External forces')
                if strcmp(trackMode,'Single (bicycle)')
                    set_param([block,'/sigma'],'LabelModeActiveChoice','0');
                else
                    set_param([block,'/sigma'],'LabelModeActiveChoice','2');
                end
            else
                switch sigmaMode
                case 'on'
                    if strcmp(trackMode,'Single (bicycle)')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','1');
                    else
                        set_param([block,'/sigma'],'LabelModeActiveChoice','3');
                    end
                otherwise
                    if strcmp(trackMode,'Single (bicycle)')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','0');
                    else
                        set_param([block,'/sigma'],'LabelModeActiveChoice','2');
                    end
                end
            end
            switch trackMode
            case 'Dual'
                set_param([block,'/Signal Routing'],'LabelModeActiveChoice','1');
                if strcmp(get_param(block,'wrapAng'),'on')
                    set_param([block,'/Signal Routing/Signal Routing Dual/state2bus/Angle Wrap'],'LabelModeActiveChoice','Wrap')
                else
                    set_param([block,'/Signal Routing/Signal Routing Dual/state2bus/Angle Wrap'],'LabelModeActiveChoice','None')
                end
            otherwise
                set_param([block,'/Signal Routing'],'LabelModeActiveChoice','0');
                if strcmp(get_param(block,'wrapAng'),'on')
                    set_param([block,'/Signal Routing/Signal Routing/state2bus/Angle Wrap'],'LabelModeActiveChoice','Wrap')
                else
                    set_param([block,'/Signal Routing/Signal Routing/state2bus/Angle Wrap'],'LabelModeActiveChoice','None')
                end
            end

            optList={'frontSteerMode';'rearSteerMode';'windMode';'muMode';'extFMode';'extMMode';'htchFMode';'htchMMode'};
            varList={'front steer';'rear steer';'wind';'friction';'noVariant';'noVariant';'noVariant';'noVariant'};
            InportNames={'WhlAngF';'WhlAngR';'WindXYZ';'Mu';'FExt';'MExt';'Fh';'Mh'};
            if strcmp(get_param(block,'htchFMode'),'on')||strcmp(get_param(block,'htchMMode'),'on')
                if strcmp(trackMode,'Single (bicycle)')
                    set_param([block,'/hitch geometry parameters'],'LabelModeActiveChoice','1');
                else
                    set_param([block,'/hitch geometry parameters'],'LabelModeActiveChoice','2');
                end
            else
                set_param([block,'/hitch geometry parameters'],'LabelModeActiveChoice','3');
            end
            for idx=1:length(optList)
                if strcmp(get_param(block,optList{idx}),'on')
                    SwitchInport(block,InportNames{idx},true)
                    if~(strcmp(varList{idx},'noVariant'))
                        if strcmp(trackMode,'Single (bicycle)')||strcmp(varList{idx},'wind')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','1');
                        else
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','3');
                        end
                    end
                else
                    SwitchInport(block,InportNames{idx},false)
                    if~(strcmp(varList{idx},'noVariant'))
                        if strcmp(trackMode,'Single (bicycle)')||strcmp(varList{idx},'wind')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','0');
                        else
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','2');
                        end
                    end
                end
            end

            for idx=1:length(paramList)
                if strcmp(get_param(block,checkboxList{idx}),'on')
                    SwitchBlock(block,labelList{idx},'Inport',[]);
                else
                    SwitchBlock(block,labelList{idx},'Constant','0');
                end
            end

            InportNames={'WhlAngF';'WhlAngR';'xdotin';'FwF';'FwR';'FExt';'MExt';'Fh';'Mh';'WindXYZ';'Mu';'AirTemp';'X_o';'Y_o';'xdot_o';'ydot_o';'psi_o';'r_o'};
            FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
            [~,PortI]=intersect(InportNames,FoundNames);
            PortI=sort(PortI);
            for i=1:length(PortI)
                set_param([block,'/',InportNames{PortI(i)}],'Port',num2str(i));
            end
        end

        ParamList={...
        'NF',[1,1],{'gt',0;'int',0};...
        'NR',[1,1],{'gt',0;'int',0};...
        'm',[1,1],{'gt',0};...
        'a',[1,1],{'gte',0};...
        'b',[1,1],{'gte',0};...
        'h',[1,1],{'gte',0};...
        'd',[1,1],{};...
        'w',[1,2],{'gte',0};...
        'X_o',[1,1],{};...
        'xdot_o',[1,1],{};...
        'Cy_f',[1,1],{'gte',0};...
        'Cy_r',[1,1],{'gte',0};...
        'sigma_f',[1,1],{'gt',0};...
        'sigma_r',[1,1],{'gt',0};...
        'Y_o',[1,1],{};...
        'ydot_o',[1,1],{};...
        'Cd',[1,1],{'gte',0};...
        'Af',[1,1],{'gte',0};...
        'Cl',[1,1],{};...
        'Izz',[1,1],{'gt',0};...
        'Cpm',[1,1],{};...
        'r_o',[1,1],{};...
        'psi_o',[1,1],{};...
        'Pabs',[1,1],{'gt',0};...
        'Tair',[1,1],{'gt',0};...
        'g',[1,1],{'gte',0};...
        'mu',[1,1],{'gte',0};...
        'xdot_tol',[1,1],{'gt',0};...
        'Fznom',[1,1],{'gt',0};...
        'Fxtire_sat',[1,1],{'gt',0};...
        'Fytire_sat',[1,1],{'gt',0};...
        };


        if strcmp(get_param(block,'htchFMode'),'on')||strcmp(get_param(block,'htchMMode'),'on')

            if strcmp(trackMode,'Single (bicycle)')
                HitchParmList={...
                'hh',[1,1],{'gte',0};...
                'dh',[1,1],{'gte',0}
                };
            else
                HitchParmList={...
                'hl',[1,1],{};...
                'hh',[1,1],{'gte',0};...
                'dh',[1,1],{'gte',0}
                };
            end

            if simStopped
                if strcmp(trackMode,'Single (bicycle)')
                    autoblksenableparameters(block,{'dh';'hh'},{'hl'},[],[]);
                else
                    autoblksenableparameters(block,{'dh';'hh';'hl'},{},[],[]);
                end
            end

        else
            HitchParmList={};
            if simStopped
                autoblksenableparameters(block,{},{'dh';'hh';'hl'},[],[]);
            end
        end

        LookupTblList={{'alpha_f_brk',{}},'Cy_f_data',{};...
        {'alpha_r_brk',{}},'Cy_r_data',{};...
        {'beta_w',{}},'Cs',{};...
        {'beta_w',{}},'Cym',{}};
        autoblkscheckparams(block,'Vehicle Body Bicycle Model',[ParamList;HitchParmList],LookupTblList);
        for idx=1:length(paramList)
            if strcmp(get_param(block,checkboxList{idx}),'off')
                if~(strcmp(paramList{idx},'xdot_o')&&strcmp(inputMode,'External longitudinal velocity'))
                    set_param([block,'/',labelList{idx},'Constant'],'Value',paramList{idx});
                end
            end
        end
        varargout{1}=0;

    case 1
        if simStopped
            muMode=get_param(block,'muMode');
            switch inputMode
            case 'External longitudinal velocity'
                set_param(block,'extxdoto','off')
                autoblksenableparameters(block,{'muMode'},[],[],[],true);
                if strcmp(muMode,'off')
                    autoblksenableparameters(block,{'Cy_f';'Cy_r';'CalphaMode';'sigmaMode';'mu'},[],[],[]);
                    autoblksenableparameters(block,[],{'xdot_o';'extxdoto'},[],[],'false');
                else
                    autoblksenableparameters(block,{'Cy_f';'Cy_r';'CalphaMode'},[],[],[]);
                    autoblksenableparameters(block,[],{'xdot_o';'extxdoto';'mu'},[],[],'false');
                end
                FznomObj.Enabled='on';
                FznomObj.Visible='on';
            case 'External forces'
                set_param(block,'muMode','off')
                autoblksenableparameters(block,{'xdot_o';'w';'extxdoto'},{'Cy_f';'Cy_r';'CalphaMode';'sigmaMode';'mu';'muMode';'sigma_f';'sigma_r';'Cy_f_data';'Cy_r_data';'alpha_f_brk';'alpha_r_brk'},[],[],'false')
                FznomObj.Visible='off';
                FznomObj.Enabled='on';
            otherwise
                autoblksenableparameters(block,{'muMode'},[],[],[],true);
                if strcmp(muMode,'off')
                    autoblksenableparameters(block,{'xdot_o';'Cy_f';'Cy_r';'CalphaMode';'mu';'extxdoto'},[],[],[]);
                else
                    autoblksenableparameters(block,{'xdot_o';'Cy_f';'Cy_r';'CalphaMode';'extxdoto'},[],[],[]);
                    autoblksenableparameters(block,[],{'mu'},[],[],'false');
                end
                FznomObj.Enabled='on';
                FznomObj.Visible='on';
            end
            [~]=vehdynlat3dof(block,3);
            [~]=vehdynlat3dof(block,2);
        end

        varargout{1}=0;

    case 2
        muMode=get_param(block,'muMode');
        switch muMode
        case 'on'
            autoblksenableparameters(block,[],{'mu'},[],[],'true');
        otherwise
            if~strcmp(inputMode,'External forces')
                autoblksenableparameters(block,{'mu'},[],[],[],'false');
            end
        end
        varargout{1}=0;

    case 3
        CalphaMode=get_param(block,'CalphaMode');
        switch CalphaMode
        case 'on'

            set_param(block,'sigmaMode','on');
            autoblksenableparameters(block,{'sigma_f';'sigma_r';'Cy_f_data';'Cy_r_data';'alpha_f_brk';'alpha_r_brk';'CalphaMode';'sigmaMode'},{'Cy_f';'Cy_r'},[],[]);
            autoblksenableparameters(block,[],{'sigmaMode'},[],[],'false');
        otherwise
            if strcmp(inputMode,'External forces')
                autoblksenableparameters(block,{'w'},{'Cy_f';'Cy_r';'CalphaMode';'sigmaMode';'sigma_f';'sigma_r';'Cy_f_data';'Cy_r_data';'alpha_f_brk';'alpha_r_brk'},[],[])
            else
                autoblksenableparameters(block,{'Cy_f';'Cy_r';'CalphaMode'},{'Cy_f_data';'Cy_r_data';'alpha_f_brk';'alpha_r_brk'},[],[]);
                autoblksenableparameters(block,{'sigmaMode'},[],[],[],'false');
            end
        end
        [~]=vehdynlat3dof(block,4);
        varargout{1}=0;

    case 4
        sigmaMode=get_param(block,'sigmaMode');
        if strcmp(inputMode,'External forces')
            autoblksenableparameters(block,{'w'},{'Cy_f';'Cy_r';'CalphaMode';'sigmaMode';'sigma_f';'sigma_r';'Cy_f_data';'Cy_r_data';'alpha_f_brk';'alpha_r_brk'},[],[])
        else

            switch sigmaMode
            case 'on'
                autoblksenableparameters(block,{'sigma_f';'sigma_r'},[],[],[]);
            otherwise
                autoblksenableparameters(block,[],{'sigma_f';'sigma_r'},[],[],'false');
            end
        end
        [~]=vehdynlat3dof(block,5);
        varargout{1}=0;

    case 5
        switch trackMode
        case 'Dual'
            autoblksenableparameters(block,{'w','d'},[],[],[]);
        otherwise
            autoblksenableparameters(block,[],{'w','d'},[],[]);
        end
        varargout{1}=0;
    case 6
        if strcmp(get_param(block,'extTamb'),'on')
            autoblksenableparameters(block,[],{'Tair'},[],[],'true');
        else
            autoblksenableparameters(block,{'Tair'},[],[],[],'true');
        end
        varargout{1}=0;
    case 7
        checkboxList={'extXo';'extxdoto';'extYo';'extydoto';'extpsio';'extro'};
        paramList={'X_o';'xdot_o';'Y_o';'ydot_o';'psi_o';'r_o'};
        for idx=1:length(checkboxList)
            if strcmp(get_param(block,checkboxList{idx}),'on')
                autoblksenableparameters(block,[],paramList{idx},[],[],'true');
            else
                if~(strcmp(paramList{idx},'xdot_o')&&strcmp(inputMode,'External longitudinal velocity'))
                    autoblksenableparameters(block,paramList{idx},[],[],[],'true');
                end
            end
        end
        varargout{1}=0;
    case 8
        varargout{1}=DrawCommands(block,trackMode);

    otherwise
        varargout{1}=0;
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
function IconInfo=DrawCommands(BlkHdl,trackMode)

    switch trackMode
    case 'Single (bicycle)'

        AliasNames={'WhlAngF','WhlAngF';...
        'Info','Info'};
        IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

        IconInfo.ImageName='3dofstrack.png';
    otherwise
        AliasNames={'WhlAngF','WhlAngF';...
        'Info','Info'};
        IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

        IconInfo.ImageName='3dofdtrack.png';
    end
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,0,0,'white');
end