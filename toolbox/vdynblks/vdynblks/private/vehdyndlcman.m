function[varargout]=vehdyndlcman(varargin)





    block=varargin{1};
    maskMode=varargin{2};

    simStopped=autoblkschecksimstopped(block,true)&&~strcmp(get_param(bdroot(block),'SimulationStatus'),'updating');










    switch maskMode
    case 0
        vehdyndlcman(block,1);
        vehdyndlcman(block,3);
        vehdyndlcman(block,5);


        ParamList={...
        't_start',[1,1],{'gte',0};...
        'vehW',[1,1],{'gte',0}};
        LookupTblList=[];



        if~isempty(LookupTblList)&&~isempty(ParamList)
            autoblkscheckparams(block,'Manuever Block',ParamList,LookupTblList);
        elseif~isempty(ParamList)
            autoblkscheckparams(block,'Manuever Block',ParamList);
        end
        if simStopped
            inputUnits=get_param(block,'xdotUnit');
            try
                if strcmp(inputUnits,'inherit')
                    error(message('autoblks_shared:autoerrDriver:invalidUnits'));
                else
                    [~]=autoblksunitconv(1,'m/s',inputUnits);
                end
            catch
                error(message('autoblks_shared:autoerrDriver:invalidUnits'));
            end
        end
        [varargout{1},varargout{2},varargout{3},varargout{4}]=vehdyndlcman(block,6);
    case 1
        ssMode=get_param(block,'ssMode');
        if simStopped
            switch ssMode
            case 'Initialize from model'
                autoblksenableparameters(block,{'t_start','xdot_r','xdotUnit'},{'ssVar'},[],{'ssGenGroupVar'},true);
                try
                    vehdynSS(block,'reset');
                catch

                end
            case 'Solve using block parameters'
                autoblksenableparameters(block,{'t_start','xdot_r','xdotUnit'},{'ssVar';'t_start'},{'ssGenGroupVar'},[],true);
                paramstruct=autoblkscheckparams(gcb,'block',{'X_o',[1,1],{};'Y_o',[1,1],{};'psi_o',[1,1],{};'ssMaxTime',[1,1],{'gt',0}});
                vehdynSS(block,'setup',paramstruct.X_o,paramstruct.Y_o,paramstruct.psi_o,paramstruct.ssMaxTime.*2);
            case 'Resume from a workspace variable'
                autoblksenableparameters(block,{'ssVar'},{'t_start'},[],{'ssGenGroupVar'},true);
                vehdynSS(block,'reset');
                vehdynSS(block,'resume');
            end
        end
        varargout{1}=[];

    case 2

        if simStopped
            paramstruct=autoblkscheckparams(gcb,'block',{'X_o',[1,1],{};'Y_o',[1,1],{};'psi_o',[1,1],{};'ssMaxTime',[1,1],{'gt',0}});
            vehdynSS(block,'reset');
            vehdynSS(block,'setup');
            vehdynSS(block,'runSS',paramstruct.X_o,paramstruct.Y_o,paramstruct.psi_o,paramstruct.ssMaxTime.*2);
        end
        varargout{1}=[];

    case 3
        if simStopped
            if strcmp(get_param(block,'centerSwitch'),'on')
                autoblksenableparameters(block,{'latRefbp','latRef'},[],[],[],true);
                set_param([block,'/ISO 3888-2/Lateral Reference'],'LabelModeActiveChoice','1');
            else
                autoblksenableparameters(block,[],{'latRefbp','latRef'},[],[],true);
                set_param([block,'/ISO 3888-2/Lateral Reference'],'LabelModeActiveChoice','0');
            end
        end
        varargout{1}=[];
    case 4

        if strcmp(get_param(block,'ssMode'),'Solve using block parameters')
            paramstruct=autoblkscheckparams(block,'block',{'X_o',[1,1],{};'Y_o',[1,1],{};'psi_o',[1,1],{};'ssMaxTime',[1,1],{'gt',0}});
            vehdynSS(block,'runTrans',paramstruct.X_o,paramstruct.Y_o,paramstruct.psi_o,paramstruct.ssMaxTime.*2);
        end
        varargout{1}=[];
    case 5
        if strcmp(get_param(block,'ssDefault'),'on')
            if simStopped
                ssMode=get_param(block,'ssMode');
                switch ssMode
                case 'Initialize from model'
                    set_param(bdroot(block),'SolverName','ode23tb','RelTol','2e-1');
                case 'Solve using block parameters'
                    set_param(bdroot(block),'SolverName','ode23','RelTol','5e-2');
                case 'Resume from a workspace variable'
                    set_param(bdroot(block),'SolverName','ode23','RelTol','5e-2');
                end
            end
        end
        varargout{1}=[];

    case 6
        paramstruct=autoblkscheckparams(block,'block',{'vehW',[1,1],{'gte',0};'XGate',[1,1],{};'latoff',[1,1],{}});
        [LPos,RPos,LNames,RNames]=vdyndlccones('3888-2',paramstruct.vehW,paramstruct.XGate,paramstruct.latoff,[]);
        if simStopped
            if strcmp(get_param(block,'use3DCones'),'on')
                set_param([block,'/Cones'],'LabelModeActiveChoice','1');
            else
                set_param([block,'/Cones'],'LabelModeActiveChoice','0');
            end
            set_param([block,'/Cones/sim3d Cones/Left Cones'],'ActorTag',LNames);
            set_param([block,'/Cones/sim3d Cones/Right Cones'],'ActorTag',RNames);
        end
        varargout{1}=LPos;
        varargout{2}=RPos;
        varargout{3}=LNames;
        varargout{4}=RNames;
    case 8
        varargout{1}=DrawCommands(block);
    otherwise
        varargout{1}=[];

    end

end


function IconInfo=DrawCommands(~)














    IconInfo=[];
end