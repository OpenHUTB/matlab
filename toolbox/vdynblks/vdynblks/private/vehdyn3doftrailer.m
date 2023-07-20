function[varargout]=vehdyn3doftrailer(varargin)


    block=varargin{1};
    maskMode=varargin{2};
    maskObj=Simulink.Mask.get(block);
    inputMode=get_param(block,'inputMode');
    FznomObj=maskObj.getParameter('Fznom');
    trackMode=get_param(block,'trackMode');
    modelname=bdroot(block);
    simMode=get_param(modelname,'SimulationStatus');
    if strcmp(simMode,'running')||strcmp(simMode,'paused')||strcmp(simMode,'compiled')
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
            [~]=vehdyn3doftrailer(block,7);

            ToggleAxleReactionForceOutports(block,trackMode);


            autoblksgetmaskparms(block,{'w_f'},true);
            if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                autoblksgetmaskparms(block,{'w_r'},true);
                autoblksgetmaskparms(block,{'w_m'},true);
                set_param(block,'w',['[',num2str(w_f),' ',num2str(w_m),' ',num2str(w_r),']']);
            elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                autoblksgetmaskparms(block,{'w_r'},true);
                set_param(block,'w',['[',num2str(w_f),' ',num2str(w_r),']']);
            else
                set_param(block,'w',num2str(w_f));
            end

            switch inputMode
            case 'External longitudinal velocity'
                if strcmp(get_param(block,'extxdoto'),'on')
                    warning(message('vdynblks:vehdynErrMsg:invalidextxdoto'));
                    set_param(block,'extxdoto','off');
                end
                SwitchInport(block,'xdotin',true)
                set_param([block,'/state'],'LabelModeActiveChoice','1');
                if strcmp(trackMode,'Single 1-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 1 Axle/Power/xdot mode'],'LabelModeActiveChoice','0');
                elseif strcmp(trackMode,'Single 2-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 2 Axle/Power/xdot mode'],'LabelModeActiveChoice','0');
                elseif strcmp(trackMode,'Single 3-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 3 Axle/Power/xdot mode'],'LabelModeActiveChoice','0');
                elseif strcmp(trackMode,'Dual 1-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/Signal Routing/Signal Routing Dual 1 Axle/Power/xdot mode'],'LabelModeActiveChoice','0');
                elseif strcmp(trackMode,'Dual 2-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/Signal Routing/Signal Routing Dual 2 Axle/Power/xdot mode'],'LabelModeActiveChoice','0');
                else
                    set_param([block,'/front forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/Signal Routing/Signal Routing Dual 3 Axle/Power/xdot mode'],'LabelModeActiveChoice','0');
                end
                SwitchInport(block,'FwF',false);
                SwitchInport(block,'FwM',false);
                SwitchInport(block,'FwR',false);
            case 'External longitudinal forces'
                SwitchInport(block,'xdotin',false)
                set_param([block,'/state'],'LabelModeActiveChoice','0');
                if strcmp(trackMode,'Single 1-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','1');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 1 Axle/Power/xdot mode'],'LabelModeActiveChoice','1');
                elseif strcmp(trackMode,'Single 2-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','1');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','1');
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 2 Axle/Power/xdot mode'],'LabelModeActiveChoice','1');
                elseif strcmp(trackMode,'Single 3-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','1');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','1');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','1');
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 3 Axle/Power/xdot mode'],'LabelModeActiveChoice','1');
                elseif strcmp(trackMode,'Dual 1-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','4');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/Signal Routing/Signal Routing Dual 1 Axle/Power/xdot mode'],'LabelModeActiveChoice','1');
                elseif strcmp(trackMode,'Dual 2-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','4');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','4');
                    set_param([block,'/Signal Routing/Signal Routing Dual 2 Axle/Power/xdot mode'],'LabelModeActiveChoice','1');
                else
                    set_param([block,'/front forces'],'LabelModeActiveChoice','4');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','4');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','4');
                    set_param([block,'/Signal Routing/Signal Routing Dual 3 Axle/Power/xdot mode'],'LabelModeActiveChoice','1');
                end

                SwitchInport(block,'FwF',true);

                if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                    SwitchInport(block,'FwM',true);
                    SwitchInport(block,'FwR',true);
                elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                    SwitchInport(block,'FwM',false);
                    SwitchInport(block,'FwR',true);
                else
                    SwitchInport(block,'FwM',false);
                    SwitchInport(block,'FwR',false);
                end

            case 'External forces'
                SwitchInport(block,'xdotin',false)
                set_param([block,'/state'],'LabelModeActiveChoice','0');
                if strcmp(get_param(block,'muMode'),'on')
                    warning(message('vdynblks:vehdynErrMsg:invalidmuMode'));
                    set_param(block,'muMode','off');
                end
                if strcmp(trackMode,'Single 1-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','2');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 1 Axle/Power/xdot mode'],'LabelModeActiveChoice','1');
                elseif strcmp(trackMode,'Single 2-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','2');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','0');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','2');
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 2 Axle/Power/xdot mode'],'LabelModeActiveChoice','1');
                elseif strcmp(trackMode,'Single 3-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','2');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','2');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','2');
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 3 Axle/Power/xdot mode'],'LabelModeActiveChoice','1');
                elseif strcmp(trackMode,'Dual 1-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','5');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/Signal Routing/Signal Routing Dual 1 Axle/Power/xdot mode'],'LabelModeActiveChoice','1');
                elseif strcmp(trackMode,'Dual 2-axle')
                    set_param([block,'/front forces'],'LabelModeActiveChoice','5');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','3');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','5');
                    set_param([block,'/Signal Routing/Signal Routing Dual 2 Axle/Power/xdot mode'],'LabelModeActiveChoice','1');
                else
                    set_param([block,'/front forces'],'LabelModeActiveChoice','5');
                    set_param([block,'/middle forces'],'LabelModeActiveChoice','5');
                    set_param([block,'/rear forces'],'LabelModeActiveChoice','5');
                    set_param([block,'/Signal Routing/Signal Routing Dual 3 Axle/Power/xdot mode'],'LabelModeActiveChoice','1');
                end
                SwitchInport(block,'FwF',true);
                if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                    SwitchInport(block,'FwM',true);
                    SwitchInport(block,'FwR',true);
                elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                    SwitchInport(block,'FwM',false);
                    SwitchInport(block,'FwR',true);
                else
                    SwitchInport(block,'FwM',false);
                    SwitchInport(block,'FwR',false);
                end

            otherwise

            end

            CalphaMode=get_param(block,'CalphaMode');
            switch CalphaMode
            case 'on'

                if strcmp(trackMode,'Single 1-axle')
                    set_param([block,'/Cy'],'LabelModeActiveChoice','9');
                elseif strcmp(trackMode,'Single 2-axle')
                    set_param([block,'/Cy'],'LabelModeActiveChoice','5');
                elseif strcmp(trackMode,'Single 3-axle')
                    set_param([block,'/Cy'],'LabelModeActiveChoice','1');
                elseif strcmp(trackMode,'Dual 1-axle')
                    set_param([block,'/Cy'],'LabelModeActiveChoice','11');
                elseif strcmp(trackMode,'Dual 2-axle')
                    set_param([block,'/Cy'],'LabelModeActiveChoice','7');
                else
                    set_param([block,'/Cy'],'LabelModeActiveChoice','3');
                end
            otherwise
                if strcmp(trackMode,'Single 1-axle')
                    set_param([block,'/Cy'],'LabelModeActiveChoice','8');
                elseif strcmp(trackMode,'Single 2-axle')
                    set_param([block,'/Cy'],'LabelModeActiveChoice','4');
                elseif strcmp(trackMode,'Single 3-axle')
                    set_param([block,'/Cy'],'LabelModeActiveChoice','0');
                elseif strcmp(trackMode,'Dual 1-axle')
                    set_param([block,'/Cy'],'LabelModeActiveChoice','10');
                elseif strcmp(trackMode,'Dual 2-axle')
                    set_param([block,'/Cy'],'LabelModeActiveChoice','6');
                else
                    set_param([block,'/Cy'],'LabelModeActiveChoice','2');
                end
            end

            optList={'frontSteerMode';'middleSteerMode';'rearSteerMode';'windMode';'muMode';'extFMode';'extMMode';'FhtchFMode';'FhtchMMode';'RhtchFMode';'RhtchMMode'};
            varList={'front steer';'middle steer';'rear steer';'wind';'friction';'noVariant';'noVariant';'noVariant';'noVariant';'noVariant';'noVariant'};
            InportNames={'WhlAngF';'WhlAngM';'WhlAngR';'WindXYZ';'Mu';'FExt';'MExt';'FhF';'MhF';'FhR';'MhR'};
            if strcmp(get_param(block,'FhtchFMode'),'on')||strcmp(get_param(block,'FhtchMMode'),'on')
                set_param([block,'/Front hitch geometry parameters'],'OverrideUsingVariant','1');
            else
                set_param([block,'/Front hitch geometry parameters'],'OverrideUsingVariant','0');
            end
            if strcmp(get_param(block,'RhtchFMode'),'on')||strcmp(get_param(block,'RhtchMMode'),'on')
                set_param([block,'/Rear hitch geometry parameters'],'LabelModeActiveChoice','1');
            else
                set_param([block,'/Rear hitch geometry parameters'],'LabelModeActiveChoice','0');
            end
            for idx=1:length(optList)
                if strcmp(get_param(block,optList{idx}),'on')
                    SwitchInport(block,InportNames{idx},true)
                    if~(strcmp(varList{idx},'noVariant'))
                        if strcmp(varList{idx},'wind')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','1');
                        elseif strcmp(trackMode,'Single 1-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','9');
                        elseif strcmp(trackMode,'Single 2-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','5');
                        elseif strcmp(trackMode,'Single 3-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','1');
                        elseif strcmp(trackMode,'Dual 1-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','11');
                        elseif strcmp(trackMode,'Dual 2-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','7');
                        elseif strcmp(trackMode,'Dual 3-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','3');
                        end
                    end
                else
                    SwitchInport(block,InportNames{idx},false)
                    if~(strcmp(varList{idx},'noVariant'))
                        if strcmp(varList{idx},'wind')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','0');
                        elseif strcmp(trackMode,'Single 1-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','8');
                        elseif strcmp(trackMode,'Single 2-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','4');
                        elseif strcmp(trackMode,'Single 3-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','0');
                        elseif strcmp(trackMode,'Dual 1-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','10');
                        elseif strcmp(trackMode,'Dual 2-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','6');
                        elseif strcmp(trackMode,'Dual 3-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','2');
                        end
                    end
                end
            end
            sigmaMode=get_param(block,'sigmaMode');
            if strcmp(inputMode,'External forces')
                if strcmp(trackMode,'Single 1-axle')
                    set_param([block,'/sigma'],'LabelModeActiveChoice','8');
                elseif strcmp(trackMode,'Single 2-axle')
                    set_param([block,'/sigma'],'LabelModeActiveChoice','4');
                elseif strcmp(trackMode,'Single 3-axle')
                    set_param([block,'/sigma'],'LabelModeActiveChoice','0');
                elseif strcmp(trackMode,'Dual 1-axle')
                    set_param([block,'/sigma'],'LabelModeActiveChoice','10');
                elseif strcmp(trackMode,'Dual 2-axle')
                    set_param([block,'/sigma'],'LabelModeActiveChoice','6');
                elseif strcmp(trackMode,'Dual 3-axle')
                    set_param([block,'/sigma'],'LabelModeActiveChoice','2');
                end
            else
                switch sigmaMode
                case 'on'
                    if strcmp(trackMode,'Single 1-axle')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','9');
                    elseif strcmp(trackMode,'Single 2-axle')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','5');
                    elseif strcmp(trackMode,'Single 3-axle')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','1');
                    elseif strcmp(trackMode,'Dual 1-axle')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','11');
                    elseif strcmp(trackMode,'Dual 2-axle')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','7');
                    elseif strcmp(trackMode,'Dual 3-axle')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','3');
                    end
                otherwise
                    if strcmp(trackMode,'Single 1-axle')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','8');
                    elseif strcmp(trackMode,'Single 2-axle')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','4');
                    elseif strcmp(trackMode,'Single 3-axle')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','0');
                    elseif strcmp(trackMode,'Dual 1-axle')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','10');
                    elseif strcmp(trackMode,'Dual 2-axle')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','6');
                    elseif strcmp(trackMode,'Dual 3-axle')
                        set_param([block,'/sigma'],'LabelModeActiveChoice','2');
                    end
                end
            end
            switch trackMode
            case 'Dual 1-axle'
                set_param([block,'/Signal Routing'],'LabelModeActiveChoice','1');
                if strcmp(get_param(block,'wrapAng'),'on')
                    set_param([block,'/Signal Routing/Signal Routing Dual 1 Axle/state2bus/Angle Wrap'],'LabelModeActiveChoice','Wrap')
                else
                    set_param([block,'/Signal Routing/Signal Routing Dual 1 Axle/state2bus/Angle Wrap'],'LabelModeActiveChoice','None')
                end
            case 'Dual 2-axle'
                set_param([block,'/Signal Routing'],'LabelModeActiveChoice','3');
                if strcmp(get_param(block,'wrapAng'),'on')
                    set_param([block,'/Signal Routing/Signal Routing Dual 2 Axle/state2bus/Angle Wrap'],'LabelModeActiveChoice','Wrap')
                else
                    set_param([block,'/Signal Routing/Signal Routing Dual 2 Axle/state2bus/Angle Wrap'],'LabelModeActiveChoice','None')
                end
            case 'Dual 3-axle'
                set_param([block,'/Signal Routing'],'LabelModeActiveChoice','5');
                if strcmp(get_param(block,'wrapAng'),'on')
                    set_param([block,'/Signal Routing/Signal Routing Dual 3 Axle/state2bus/Angle Wrap'],'LabelModeActiveChoice','Wrap')
                else
                    set_param([block,'/Signal Routing/Signal Routing Dual 3 Axle/state2bus/Angle Wrap'],'LabelModeActiveChoice','None')
                end
            case 'Single 1-axle'
                set_param([block,'/Signal Routing'],'LabelModeActiveChoice','0');
                if strcmp(get_param(block,'wrapAng'),'on')
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 1 Axle/state2bus/Angle Wrap'],'LabelModeActiveChoice','Wrap')
                else
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 1 Axle/state2bus/Angle Wrap'],'LabelModeActiveChoice','None')
                end
            case 'Single 2-axle'
                set_param([block,'/Signal Routing'],'LabelModeActiveChoice','2');
                if strcmp(get_param(block,'wrapAng'),'on')
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 2 Axle/state2bus/Angle Wrap'],'LabelModeActiveChoice','Wrap')
                else
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 2 Axle/state2bus/Angle Wrap'],'LabelModeActiveChoice','None')
                end
            otherwise
                set_param([block,'/Signal Routing'],'LabelModeActiveChoice','4');
                if strcmp(get_param(block,'wrapAng'),'on')
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 3 Axle/state2bus/Angle Wrap'],'LabelModeActiveChoice','Wrap')
                else
                    set_param([block,'/Signal Routing/Signal Routing Bicycle 3 Axle/state2bus/Angle Wrap'],'LabelModeActiveChoice','None')
                end
            end

            optList={'frontSteerMode';'middleSteerMode';'rearSteerMode';'windMode';'muMode';'extFMode';'extMMode';'FhtchFMode';'FhtchMMode';'RhtchFMode';'RhtchMMode'};
            varList={'front steer';'middle steer';'rear steer';'wind';'friction';'noVariant';'noVariant';'noVariant';'noVariant';'noVariant';'noVariant'};
            InportNames={'WhlAngF';'WhlAngM';'WhlAngR';'WindXYZ';'Mu';'FExt';'MExt';'FhF';'MhF';'FhR';'MhR'};
            if strcmp(get_param(block,'FhtchFMode'),'on')||strcmp(get_param(block,'FhtchMMode'),'on')
                set_param([block,'/Front hitch geometry parameters'],'OverrideUsingVariant','1');
            else
                set_param([block,'/Front hitch geometry parameters'],'OverrideUsingVariant','0');
            end
            if strcmp(get_param(block,'RhtchFMode'),'on')||strcmp(get_param(block,'RhtchMMode'),'on')
                set_param([block,'/Rear hitch geometry parameters'],'LabelModeActiveChoice','1');
            else
                set_param([block,'/Rear hitch geometry parameters'],'LabelModeActiveChoice','0');
            end
            for idx=1:length(optList)
                if strcmp(get_param(block,optList{idx}),'on')
                    SwitchInport(block,InportNames{idx},true)
                    if~(strcmp(varList{idx},'noVariant'))
                        if strcmp(varList{idx},'wind')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','1');
                        elseif strcmp(trackMode,'Single 1-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','9');
                        elseif strcmp(trackMode,'Single 2-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','5');
                        elseif strcmp(trackMode,'Single 3-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','1');
                        elseif strcmp(trackMode,'Dual 1-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','11');
                        elseif strcmp(trackMode,'Dual 2-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','7');
                        elseif strcmp(trackMode,'Dual 3-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','3');
                        end
                    end
                else
                    SwitchInport(block,InportNames{idx},false)
                    if~(strcmp(varList{idx},'noVariant'))
                        if strcmp(varList{idx},'wind')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','0');
                        elseif strcmp(trackMode,'Single 1-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','8');
                        elseif strcmp(trackMode,'Single 2-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','4');
                        elseif strcmp(trackMode,'Single 3-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','0');
                        elseif strcmp(trackMode,'Dual 1-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','10');
                        elseif strcmp(trackMode,'Dual 2-axle')
                            set_param([block,'/',varList{idx}],'LabelModeActiveChoice','6');
                        elseif strcmp(trackMode,'Dual 3-axle')
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

            InportNames={'WhlAngF';'WhlAngM';'WhlAngR';'xdotin';'FwF';'FwM';'FwR';'FExt';'MExt';'FhF';'MhF';'FhR';'MhR';'WindXYZ';'Mu';'AirTemp';'X_o';'Y_o';'xdot_o';'ydot_o';'psi_o';'r_o'};
            FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
            [~,PortI]=intersect(InportNames,FoundNames);
            PortI=sort(PortI);
            for i=1:length(PortI)
                set_param([block,'/',InportNames{PortI(i)}],'Port',num2str(i));
            end
        end

        BaseParmList={...
        'NF',[1,1],{'gt',0;'int',0};...
        'a',[1,1],{'gte',-1e6;'lte',1e6};...
        'm',[1,1],{'gt',0};...
        'h',[1,1],{'gte',0};...
        'X_o',[1,1],{};...
        'xdot_o',[1,1],{};...
        'sigma_f',[1,1],{'gt',0};...
        'Cy_f',[1,1],{'gte',0};...
        'w_f',[1,1],{'gt',0};...
        'Y_o',[1,1],{};...
        'ydot_o',[1,1],{};...
        'Cd',[1,1],{'gte',0};...
        'Af',[1,1],{'gte',0};...
        'Cl',[1,1],{'gte',0};...
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


        if strcmp(trackMode,'Dual 3-axle')

            if strcmp(get_param(block,'CalphaMode'),'on')

                AxleParmList={...
                'NM',[1,1],{'gt',0;'int',0};...
                'NR',[1,1],{'gt',0;'int',0};...
                'b',[1,1],{'gte',-1e6;'lte',1e6};...
                'c',[1,1],{'gte',-1e6;'lte',1e6};...
                'd',[1,1],{};...
                'sigma_m',[1,1],{'gt',0};...
                'sigma_r',[1,1],{'gt',0};...
                'w_m',[1,1],{'gt',0};...
                'w_r',[1,1],{'gt',0}};

                LookupTblList={{'alpha_f_brk',{}},'Cy_f_data',{};...
                {'alpha_m_brk',{}},'Cy_m_data',{};...
                {'alpha_r_brk',{}},'Cy_r_data',{};...
                {'beta_w',{}},'Cs',{};...
                {'beta_w',{}},'Cym',{}};
            else
                AxleParmList={...
                'NM',[1,1],{'gt',0;'int',0};...
                'NR',[1,1],{'gt',0;'int',0};...
                'b',[1,1],{'gte',-1e6;'lte',1e6};...
                'c',[1,1],{'gte',-1e6;'lte',1e6};...
                'd',[1,1],{};...
                'Cy_m',[1,1],{'gte',0};...
                'Cy_r',[1,1],{'gte',0};...
                'sigma_m',[1,1],{'gt',0};...
                'sigma_r',[1,1],{'gt',0};...
                'w_m',[1,1],{'gt',0};...
                'w_r',[1,1],{'gt',0}};

                LookupTblList={{'beta_w',{}},'Cs',{};...
                {'beta_w',{}},'Cym',{}};
            end

        elseif strcmp(trackMode,'Single 3-axle')

            if strcmp(get_param(block,'CalphaMode'),'on')

                AxleParmList={...
                'NM',[1,1],{'gt',0;'int',0};...
                'NR',[1,1],{'gt',0;'int',0};...
                'b',[1,1],{'gte',-1e6;'lte',1e6};...
                'c',[1,1],{'gte',-1e6;'lte',1e6};...
                'sigma_m',[1,1],{'gt',0};...
                'sigma_r',[1,1],{'gt',0}};

                LookupTblList={{'alpha_f_brk',{}},'Cy_f_data',{};...
                {'alpha_m_brk',{}},'Cy_m_data',{};...
                {'alpha_r_brk',{}},'Cy_r_data',{};...
                {'beta_w',{}},'Cs',{};...
                {'beta_w',{}},'Cym',{}};
            else

                AxleParmList={...
                'NM',[1,1],{'gt',0;'int',0};...
                'NR',[1,1],{'gt',0;'int',0};...
                'b',[1,1],{'gte',-1e6;'lte',1e6};...
                'c',[1,1],{'gte',-1e6;'lte',1e6};...
                'Cy_m',[1,1],{'gte',0};...
                'Cy_r',[1,1],{'gte',0};...
                'sigma_m',[1,1],{'gt',0};...
                'sigma_r',[1,1],{'gt',0}};

                LookupTblList={{'beta_w',{}},'Cs',{};...
                {'beta_w',{}},'Cym',{}};
            end

        elseif strcmp(trackMode,'Dual 2-axle')

            if strcmp(get_param(block,'CalphaMode'),'on')

                AxleParmList={...
                'NR',[1,1],{'gt',0;'int',0};...
                'c',[1,1],{'gte',-1e6;'lte',1e6};...
                'd',[1,1],{};...
                'sigma_r',[1,1],{'gt',0};...
                'w_r',[1,1],{'gt',0}};

                LookupTblList={{'alpha_f_brk',{}},'Cy_f_data',{};...
                {'alpha_r_brk',{}},'Cy_r_data',{};...
                {'beta_w',{}},'Cs',{};...
                {'beta_w',{}},'Cym',{}};
            else

                AxleParmList={...
                'NR',[1,1],{'gt',0;'int',0};...
                'c',[1,1],{'gte',-1e6;'lte',1e6};...
                'd',[1,1],{};...
                'Cy_r',[1,1],{'gte',0};...
                'sigma_r',[1,1],{'gt',0};...
                'w_r',[1,1],{'gt',0}};

                LookupTblList={{'beta_w',{}},'Cs',{};...
                {'beta_w',{}},'Cym',{}};
            end

        elseif strcmp(trackMode,'Single 2-axle')

            if strcmp(get_param(block,'CalphaMode'),'on')

                AxleParmList={...
                'NR',[1,1],{'gt',0;'int',0};...
                'c',[1,1],{'gte',-1e6;'lte',1e6};...
                'sigma_r',[1,1],{'gt',0};
                'w_r',[1,1],{'gt',0}};

                LookupTblList={{'alpha_f_brk',{}},'Cy_f_data',{};...
                {'alpha_r_brk',{}},'Cy_r_data',{};...
                {'beta_w',{}},'Cs',{};...
                {'beta_w',{}},'Cym',{}};
            else

                AxleParmList={...
                'NR',[1,1],{'gt',0;'int',0};...
                'c',[1,1],{'gte',-1e6;'lte',1e6};...
                'Cy_r',[1,1],{'gte',0};...
                'sigma_r',[1,1],{'gt',0};...
                'w_r',[1,1],{'gt',0}};

                LookupTblList={{'beta_w',{}},'Cs',{};...
                {'beta_w',{}},'Cym',{}};
            end


        elseif strcmp(trackMode,'Dual 1-axle')

            if strcmp(get_param(block,'CalphaMode'),'on')

                AxleParmList={'d',[1,1],{}};

                LookupTblList={{'alpha_f_brk',{}},'Cy_f_data',{};...
                {'beta_w',{}},'Cs',{};...
                {'beta_w',{}},'Cym',{}};
            else

                AxleParmList={'d',[1,1],{}};

                LookupTblList={{'beta_w',{}},'Cs',{};...
                {'beta_w',{}},'Cym',{}};
            end

        elseif strcmp(trackMode,'Single 1-axle')

            if strcmp(get_param(block,'CalphaMode'),'on')

                AxleParmList={};

                LookupTblList={{'alpha_f_brk',{}},'Cy_f_data',{};...
                {'beta_w',{}},'Cs',{};...
                {'beta_w',{}},'Cym',{}};
            else

                AxleParmList={};

                LookupTblList={{'beta_w',{}},'Cs',{};...
                {'beta_w',{}},'Cym',{}};
            end

        end


        if strcmp(get_param(block,'FhtchFMode'),'on')||strcmp(get_param(block,'FhtchMMode'),'on')

            FHitchParmList={...
            'hh_f',[1,1],{'gte',0};...
            'dh_f',[1,1],{'gte',0};...
            'hl_f',[1,1],{'gte',0}
            };

            autoblksgetmaskparms(block,{'dh_f'},true);
            L=-dh_f;

            FHitchParmEnableList={'hh_f';'dh_f';'hl_f'};
            FHitchParmDisableList={};

        else

            L=[];
            FHitchParmList={};

            FHitchParmEnableList={};
            FHitchParmDisableList={'hh_f';'dh_f';'hl_f'};

        end

        if strcmp(get_param(block,'RhtchFMode'),'on')||strcmp(get_param(block,'RhtchMMode'),'on')

            RHitchParmList={...
            'hh_r',[1,1],{'gte',0};...
            'dh_r',[1,1],{'gte',0};...
            'hl_r',[1,1],{'gte',0}
            };

            RHitchParmEnableList={'hh_r';'dh_r';'hl_r'};
            RHitchParmDisableList={};

        else

            RHitchParmList={};

            RHitchParmEnableList={};
            RHitchParmDisableList={'hh_r';'dh_r';'hl_r'};

        end

        ParamList=[BaseParmList;AxleParmList;FHitchParmList;RHitchParmList];
        ParamEnableList=[FHitchParmEnableList;RHitchParmEnableList];
        ParamDisableList=[FHitchParmDisableList;RHitchParmDisableList];
        autoblksenableparameters(block,ParamEnableList,ParamDisableList);

        autoblkscheckparams(block,'Vehicle Body Bicycle Model',ParamList,LookupTblList);

        autoblksgetmaskparms(block,{'a'},true);

        if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
            autoblksgetmaskparms(block,{'b'},true);
            autoblksgetmaskparms(block,{'c'},true);
            L=[L;a;b;c];
        elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
            autoblksgetmaskparms(block,{'c'},true);
            L=[L;a;c];
        else
            L=[L;a];
        end

        set_param(block,'Lcpm',num2str(abs(max(L)-min(L))));

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
                    autoblksenableparameters(block,[],{'xdot_o';'extxdoto'},[],[],'false');
                    if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                        autoblksenableparameters(block,{'Cy_f';'Cy_m';'Cy_r';'CalphaMode';'sigmaMode';'mu'},[],[],[]);
                    elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                        autoblksenableparameters(block,{'Cy_f';'Cy_r';'CalphaMode';'sigmaMode';'mu'},[],[],[]);
                    else
                        autoblksenableparameters(block,{'Cy_f';'CalphaMode';'sigmaMode';'mu'},[],[],[]);
                    end
                else
                    autoblksenableparameters(block,[],{'xdot_o';'extxdoto';'mu'},[],[],'false');
                    if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                        autoblksenableparameters(block,{'Cy_f';'Cy_m';'Cy_r';'CalphaMode'},[],[],[]);
                    elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                        autoblksenableparameters(block,{'Cy_f';'Cy_r';'CalphaMode'},[],[],[]);
                    else
                        autoblksenableparameters(block,{'Cy_f';'CalphaMode'},[],[],[]);
                    end
                end
                FznomObj.Enabled='on';
                FznomObj.Visible='on';
            case 'External forces'
                set_param(block,'muMode','off')
                if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                    autoblksenableparameters(block,{'xdot_o';'w_f';'w_m';'w_r';'extxdoto'},{'Cy_f';'Cy_m';'Cy_r';'CalphaMode';'sigmaMode';'mu';'muMode';'sigma_f';'sigma_m';'sigma_r';'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk'},[],[],'false');
                elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                    autoblksenableparameters(block,{'xdot_o';'w_f';'w_r';'extxdoto'},{'w_m';'Cy_f';'Cy_m';'Cy_r';'CalphaMode';'sigmaMode';'mu';'muMode';'sigma_f';'sigma_m';'sigma_r';'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk'},[],[],'false');
                else
                    autoblksenableparameters(block,{'xdot_o';'w_f';'extxdoto'},{'w_m';'w_r';'Cy_f';'Cy_m';'Cy_r';'CalphaMode';'sigmaMode';'mu';'muMode';'sigma_f';'sigma_m';'sigma_r';'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk'},[],[],'false');
                end
                FznomObj.Visible='off';
                FznomObj.Enabled='on';
            otherwise
                autoblksenableparameters(block,{'muMode'},[],[],[],true);
                if strcmp(muMode,'off')
                    if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                        autoblksenableparameters(block,{'xdot_o';'Cy_f';'Cy_m';'Cy_r';'CalphaMode';'mu';'extxdoto'},[],[],[]);
                    elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                        autoblksenableparameters(block,{'xdot_o';'Cy_f';'Cy_r';'CalphaMode';'mu';'extxdoto'},[],[],[]);
                    else
                        autoblksenableparameters(block,{'xdot_o';'Cy_f';'CalphaMode';'mu';'extxdoto'},[],[],[]);
                    end
                else

                    autoblksenableparameters(block,[],{'mu'},[],[],'false');

                    if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                        autoblksenableparameters(block,{'xdot_o';'Cy_f';'Cy_m';'Cy_r';'CalphaMode';'extxdoto'},[],[],[]);
                    elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                        autoblksenableparameters(block,{'xdot_o';'Cy_f';'Cy_r';'CalphaMode';'extxdoto'},[],[],[]);
                    else
                        autoblksenableparameters(block,{'xdot_o';'Cy_f';'CalphaMode';'extxdoto'},[],[],[]);
                    end

                end
                FznomObj.Enabled='on';
                FznomObj.Visible='on';
            end
            [~]=vehdyn3doftrailer(block,3);
            [~]=vehdyn3doftrailer(block,2);
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
            if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                autoblksenableparameters(block,{'sigma_f';'sigma_m';'sigma_r';'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk';'CalphaMode';'sigmaMode'},{'Cy_f';'Cy_m';'Cy_r'},[],[]);
            elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                autoblksenableparameters(block,{'sigma_f';'sigma_r';'Cy_f_data';'Cy_r_data';'alpha_f_brk';'alpha_r_brk';'CalphaMode';'sigmaMode'},{'Cy_f';'Cy_m';'Cy_r';'sigma_m';'Cy_m_data';'alpha_m_brk'},[],[]);
            else
                autoblksenableparameters(block,{'sigma_f';'Cy_f_data';'alpha_f_brk';'CalphaMode';'sigmaMode'},{'Cy_f';'Cy_m';'Cy_r';'sigma_m';'Cy_m_data';'alpha_m_brk';'sigma_r';'Cy_r_data';'alpha_r_brk'},[],[]);
            end
            autoblksenableparameters(block,[],{'sigmaMode'},[],[],'false');
        otherwise
            if strcmp(inputMode,'External forces')
                if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                    autoblksenableparameters(block,{'w_f';'w_m';'w_r'},{'Cy_f';'Cy_m';'Cy_r';'CalphaMode';'sigmaMode';'sigma_f';'sigma_m';'sigma_r';'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk'},[],[]);
                elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                    autoblksenableparameters(block,{'w_f';'w_r'},{'w_m';'Cy_f';'Cy_m';'Cy_r';'CalphaMode';'sigmaMode';'sigma_f';'sigma_m';'sigma_r';'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk'},[],[]);
                else
                    autoblksenableparameters(block,{'w_f'},{'w_m';'w_r';'Cy_f';'Cy_m';'Cy_r';'CalphaMode';'sigmaMode';'sigma_f';'sigma_m';'sigma_r';'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk'},[],[]);
                end
            else
                if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                    autoblksenableparameters(block,{'Cy_f';'Cy_m';'Cy_r';'CalphaMode'},{'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk'},[],[]);
                elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                    autoblksenableparameters(block,{'Cy_f';'Cy_r';'CalphaMode'},{'Cy_m';'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk'},[],[]);
                else
                    autoblksenableparameters(block,{'Cy_f';'CalphaMode'},{'Cy_m';'Cy_r';'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk'},[],[]);
                end
                autoblksenableparameters(block,{'sigmaMode'},[],[],[],'false');
            end
        end
        [~]=vehdyn3doftrailer(block,4);
        varargout{1}=0;

    case 4
        sigmaMode=get_param(block,'sigmaMode');
        if strcmp(inputMode,'External forces')
            if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                autoblksenableparameters(block,{'w_f';'w_m';'w_r'},{'Cy_f';'Cy_m';'Cy_r';'CalphaMode';'sigmaMode';'sigma_f';'sigma_m';'sigma_r';'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk'},[],[]);
            elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                autoblksenableparameters(block,{'w_f';'w_r'},{'w_m';'Cy_f';'Cy_m';'Cy_r';'CalphaMode';'sigmaMode';'sigma_f';'sigma_m';'sigma_r';'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk'},[],[]);
            else
                autoblksenableparameters(block,{'w_f'},{'w_m';'w_r';'Cy_f';'Cy_m';'Cy_r';'CalphaMode';'sigmaMode';'sigma_f';'sigma_m';'sigma_r';'Cy_f_data';'Cy_m_data';'Cy_r_data';'alpha_f_brk';'alpha_m_brk';'alpha_r_brk'},[],[]);
            end
        else

            switch sigmaMode
            case 'on'
                if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                    autoblksenableparameters(block,{'sigma_f';'sigma_m';'sigma_r'},[],[],[]);
                elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                    autoblksenableparameters(block,{'sigma_f';'sigma_r'},{'sigma_m'},[],[]);
                else
                    autoblksenableparameters(block,{'sigma_f'},{'sigma_m';'sigma_r'},[],[]);
                end
            otherwise
                if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')
                    autoblksenableparameters(block,[],{'sigma_f';'sigma_m';'sigma_r'},[],[],'false');
                elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')
                    autoblksenableparameters(block,[],{'sigma_f';'sigma_r'},{'sigma_m'},[],'false');
                else
                    autoblksenableparameters(block,[],{'sigma_f'},{'sigma_m';'sigma_r'},[],'false');
                end
            end
        end
        [~]=vehdyn3doftrailer(block,5);
        varargout{1}=0;

    case 5
        switch trackMode
        case 'Dual 3-axle'
            if strcmp(get_param(block,'CalphaMode'),'on')
                if~strcmp(get_param(block,'inputMode'),'External forces')
                    autoblksenableparameters(block,{'w_f','w_m','w_r','d','b','c','middleSteerMode','rearSteerMode','NM','Cy_m_data','alpha_m_brk','NR','Cy_r_data','alpha_r_brk'},[],[],[]);
                else
                    autoblksenableparameters(block,{'w_f','w_m','w_r','d','b','c','middleSteerMode','rearSteerMode','NM','NR'},[],[],[]);
                end
            else
                if~strcmp(get_param(block,'inputMode'),'External forces')
                    autoblksenableparameters(block,{'w_f','w_m','w_r','d','b','c','middleSteerMode','rearSteerMode','NM','Cy_m','sigma_m','NR','Cy_r','sigma_r'},[],[],[]);
                else
                    autoblksenableparameters(block,{'w_f','w_m','w_r','d','b','c','middleSteerMode','rearSteerMode','NM','NR'},[],[],[]);
                end
            end
        case 'Single 3-axle'
            if strcmp(get_param(block,'CalphaMode'),'on')
                if~strcmp(get_param(block,'inputMode'),'External forces')
                    autoblksenableparameters(block,{'b','middleSteerMode','NM','Cy_m_data','alpha_m_brk','c','rearSteerMode','NR','Cy_r_data','alpha_r_brk'},{'w_f','w_m','w_r','d'},[],[]);
                else
                    autoblksenableparameters(block,{'b','middleSteerMode','NM','c','rearSteerMode','NR'},{'w_f','w_m','w_r','d'},[],[]);
                end
            else
                if~strcmp(get_param(block,'inputMode'),'External forces')
                    autoblksenableparameters(block,{'b','middleSteerMode','NM','Cy_m','sigma_m','c','rearSteerMode','NR','Cy_r','sigma_r'},{'w_f','w_m','w_r','d'},[],[]);
                else
                    autoblksenableparameters(block,{'b','middleSteerMode','NM','c','rearSteerMode','NR'},{'w_f','w_m','w_r','d'},[],[]);
                end
            end
        case 'Dual 1-axle'
            set_param(block,'middleSteerMode','off');
            set_param(block,'rearSteerMode','off');
            autoblksenableparameters(block,{'w_f','d'},{'b','c','middleSteerMode','rearSteerMode','w_m','w_r','NM','NR','Cy_m','sigma_m','Cy_m_data','alpha_m_brk','Cy_r','sigma_r','Cy_r_data','alpha_r_brk'},[],[]);
        case 'Dual 2-axle'
            set_param(block,'middleSteerMode','off');
            autoblksenableparameters(block,{'w_f','w_r','d','NR','c','rearSteerMode'},{'b','middleSteerMode','w_m','NM','Cy_m','sigma_m','Cy_m_data','alpha_m_brk'},[],[]);
        case 'Single 1-axle'
            set_param(block,'middleSteerMode','off');
            set_param(block,'rearSteerMode','off');
            autoblksenableparameters(block,{},{'w_f','w_m','w_r','b','c','middleSteerMode','rearSteerMode','d','NM','NR','Cy_m','sigma_m','Cy_m_data','alpha_m_brk','Cy_r','sigma_r','Cy_r_data','alpha_r_brk'},[],[]);
        case 'Single 2-axle'
            set_param(block,'middleSteerMode','off');
            autoblksenableparameters(block,{'c','rearSteerMode','NR'},{'w_f','w_m','w_r','b','middleSteerMode','d','NM','Cy_m','sigma_m','Cy_m_data','alpha_m_brk'},[],[]);
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


function ToggleAxleReactionForceOutports(block,trackMode)

    FzFhdl=find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','Name','FzF');
    FzMhdl=find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','Name','FzM');
    FzRhdl=find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','Name','FzR');

    if strcmp(trackMode,'Single 3-axle')||strcmp(trackMode,'Dual 3-axle')

        if isempty(FzMhdl)
            SwitchBlock(block,'FzM','Outport',[]);
            set_param([block,'/FzM'],'Port',num2str(str2double(get_param(FzFhdl{1},'Port'))+1));
        end

        if isempty(FzRhdl)
            SwitchBlock(block,'FzR','Outport',[]);
            set_param([block,'/FzR'],'Port',num2str(str2double(get_param(FzFhdl{1},'Port'))+2));
        end

    elseif strcmp(trackMode,'Single 2-axle')||strcmp(trackMode,'Dual 2-axle')

        if~isempty(FzMhdl)
            SwitchBlock(block,'FzM','Terminator',[]);
        end

        if isempty(FzRhdl)
            SwitchBlock(block,'FzR','Outport',[]);
            set_param([block,'/FzR'],'Port',num2str(str2double(get_param(FzFhdl{1},'Port'))+1));
        end

    else

        SwitchBlock(block,'FzM','Terminator',[]);
        SwitchBlock(block,'FzR','Terminator',[]);

    end
end


function IconInfo=DrawCommands(BlkHdl,trackMode)

    switch trackMode
    case 'Single 1-axle'

        AliasNames=[{'WhlAngF';'WhlAngM';'WhlAngR'},{'WhlAngF';'WhlAngM';'WhlAngR'}];
        IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

        IconInfo.ImageName='3dof1axletrailerstrack.png';
    case 'Single 2-axle'

        AliasNames=[{'WhlAngF';'WhlAngM';'WhlAngR'},{'WhlAngF';'WhlAngM';'WhlAngR'}];
        IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

        IconInfo.ImageName='3dof2axlestrailerstrack.png';
    case 'Single 3-axle'

        AliasNames=[{'WhlAngF';'WhlAngM';'WhlAngR'},{'WhlAngF';'WhlAngM';'WhlAngR'}];
        IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

        IconInfo.ImageName='3dof3axlestrailerstrack.png';
    case 'Dual 1-axle'
        AliasNames=[{'WhlAngF';'WhlAngM';'WhlAngR'},{'WhlAngF';'WhlAngM';'WhlAngR'}];
        IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

        IconInfo.ImageName='3dof1axletrailer.png';
    case 'Dual 2-axle'
        AliasNames=[{'WhlAngF';'WhlAngM';'WhlAngR'},{'WhlAngF';'WhlAngM';'WhlAngR'}];
        IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

        IconInfo.ImageName='3dof2axletrailer.png';
    otherwise
        AliasNames=[{'WhlAngF';'WhlAngM';'WhlAngR'},{'WhlAngF';'WhlAngM';'WhlAngR'}];
        IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

        IconInfo.ImageName='3dof3axletrailer.png';
    end
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,0.65,0,0,'white');
end