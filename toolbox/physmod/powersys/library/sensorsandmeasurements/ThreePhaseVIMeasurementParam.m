function[Kv,Ki]=ThreePhaseVIMeasurementParam(block,Vpu,VpuLL,Ipu,Vbase,Pbase,PhasorSimulation,OutputType)

















    Kv=1;
    Ki=1;





    if isequal('stopped',get_param(bdroot(block),'SimulationStatus'));


        Vbase=1;
        Pbase=1;
    end



    VoltageMeasurement=get_param(block,'VoltageMeasurement');
    MeasureVoltageGround=strcmp('phase-to-ground',VoltageMeasurement);
    MeasureVoltagePhase=strcmp('phase-to-phase',VoltageMeasurement);
    MeasureCurrent=strcmp('yes',get_param(block,'CurrentMeasurement'));



    RB=get_param([block,'/Model'],'Referenceblock');
    RBi=RB(find(RB=='/')+1:end);

    if MeasureVoltagePhase&&MeasureCurrent&&~strcmp('VI_phase',RBi)
        RB=[RB(1:(find(RB=='/'))),'VI_phase'];
        set_param([block,'/Model'],'Referenceblock',RB)

    elseif MeasureVoltageGround&&MeasureCurrent&&~strcmp('VI',RBi)
        RB=[RB(1:(find(RB=='/'))),'VI'];
        set_param([block,'/Model'],'Referenceblock',RB)

    elseif MeasureVoltagePhase&&~MeasureCurrent&&~strcmp('V_phase',RBi)
        RB=[RB(1:(find(RB=='/'))),'V_phase'];
        set_param([block,'/Model'],'Referenceblock',RB)

    elseif MeasureVoltageGround&&~MeasureCurrent&&~strcmp('V',RBi)
        RB=[RB(1:(find(RB=='/'))),'V'];
        set_param([block,'/Model'],'Referenceblock',RB)

    elseif~MeasureVoltagePhase&&~MeasureVoltageGround&&MeasureCurrent&&~strcmp('I',RBi)
        RB=[RB(1:(find(RB=='/'))),'I'];
        set_param([block,'/Model'],'Referenceblock',RB)

    elseif~MeasureVoltagePhase&&~MeasureVoltageGround&&~MeasureCurrent&&~strcmp('NO',RBi)
        RB=[RB(1:(find(RB=='/'))),'NO'];
        set_param([block,'/Model'],'Referenceblock',RB)

    end



    RB=get_param([block,'/Mode V'],'Referenceblock');
    RBi=RB(find(RB=='/')+1:end);

    if MeasureVoltagePhase||MeasureVoltageGround


        if Vpu||VpuLL

            if isempty(Vbase)
                VbaseEntry=get_param(block,'Vbase');
                message=['Undefined function or variable ''',VbaseEntry,''' for the Base Voltage parameter of the ',strrep(getfullname(block),char(10),' '),' block.'];
                warndlg(message);
                warning('SpecializedPowerSystems:UndefinedVariable',message);
                Vbase=1;
            end
            if Vbase==0
                message=['Base Voltage parameter of the ',strrep(getfullname(block),char(10),' '),' block cannot be set to zero.'];
                warndlg(message);
                warning('SpecializedPowerSystems:InvalidParameter',message);
                Vbase=1;
            end
        end

        if strcmp('phase-to-ground',VoltageMeasurement);
            if Vpu
                Kv=1/(Vbase/sqrt(3)*sqrt(2));
            end
        else
            if Vpu
                Kv=1/(Vbase/sqrt(3)*sqrt(2));
            end
            if VpuLL
                Kv=1/(Vbase*sqrt(2));
            end
        end

        if PhasorSimulation
            if~strcmp(OutputType,RBi)
                RB=[RB(1:(find(RB=='/'))),OutputType];
                set_param([block,'/Mode V'],'Referenceblock',RB);
            end
        else
            if~strcmp('Complex',RBi)
                RB=[RB(1:(find(RB=='/'))),'Complex'];
                set_param([block,'/Mode V'],'Referenceblock',RB);
            end
        end


        WantVlabel=strcmp('on',get_param(block,'SetLabelV'));


        Vabc=get_param([block,'/Vabc'],'Blocktype');

        if WantVlabel
            if~strcmp(Vabc,'Goto')
                replace_block(block,'LookUnderMasks','on','FollowLinks','on','Name','Vabc','goto','noprompt');
            end
            set_param([block,'/Vabc'],'GotoTag',get_param(block,'LabelV'),'TagVisibility','Global');
        else
            if~strcmp(Vabc,'Outport')
                replace_block(block,'LookUnderMasks','on','FollowLinks','on','Name','Vabc','Outport','noprompt');
                set_param([block,'/Vabc'],'Port','1');
            end
        end

    else
        if~strcmp('Complex',RBi)
            RB=[RB(1:(find(RB=='/'))),'Complex'];
            set_param([block,'/Mode V'],'ReferenceBlock',RB)
        end

        if~strcmp(get_param([block,'/Vabc'],'Blocktype'),'Terminator')
            replace_block(block,'LookUnderMasks','on','FollowLinks','on','Name','Vabc','Terminator','noprompt');
        end
    end



    RB=get_param([block,'/Mode I'],'Referenceblock');
    RBi=RB(find(RB=='/')+1:end);

    if MeasureCurrent


        if Ipu

            if isempty(Vbase)
                VbaseEntry=get_param(block,'Vbase');
                message=['Undefined function or variable ''',VbaseEntry,...
                ''' for the Base Voltage parameter of the ',strrep(getfullname(block),char(10),' '),' block.'];
                warndlg(message);
                warning('SpecializedPowerSystems:UndefinedVariable',message);
                Vbase=1;
            end
            if Vbase==0
                message=['Base Voltage parameter of the ',strrep(getfullname(block),char(10),' '),...
                ' block cannot be set to zero.'];
                warndlg(message);
                warning('SpecializedPowerSystems:InvalidParameter',message);
                Vbase=1;
            end
            if isempty(Pbase)
                PbaseEntry=get_param(block,'Pbase');
                message=['Undefined function or variable ''',PbaseEntry,''' for the Base Power parameter of the ',...
                strrep(getfullname(block),char(10),' '),' block.'];
                warndlg(message);
                warning('SpecializedPowerSystems:UndefinedVariable',message);
                Pbase=1;
            end
            if Pbase==0
                message=['Base Power parameter of the ',strrep(getfullname(block),...
                char(10),' '),' block cannot be set to zero.'];
                warndlg(message);
                warning('SpecializedPowerSystems:InvalidParameter',message);
                Pbase=1;
            end

            Ki=1/(Pbase/Vbase/sqrt(3)*sqrt(2));

        end

        if PhasorSimulation
            if~strcmp(OutputType,RBi)
                RB=[RB(1:(find(RB=='/'))),OutputType];
                set_param([block,'/Mode I'],'Referenceblock',RB);
            end
        else
            if~strcmp('Complex',RBi)
                RB=[RB(1:(find(RB=='/'))),'Complex'];
                set_param([block,'/Mode I'],'Referenceblock',RB);
            end
        end


        WantIlabel=strcmp('on',get_param(block,'SetLabelI'));


        Iabc=get_param([block,'/Iabc'],'Blocktype');

        if WantIlabel
            if~strcmp(Iabc,'Goto')
                replace_block(block,'LookUnderMasks','on','FollowLinks','on','Name','Iabc','goto','noprompt');
            end
            set_param([block,'/Iabc'],'GotoTag',get_param(block,'LabelI'),'TagVisibility','Global');
        else
            if~strcmp(Iabc,'Outport')
                replace_block(block,'LookUnderMasks','on','FollowLinks','on','Name','Iabc','Outport','noprompt');
            end
        end

    else
        if~strcmp('Complex',RBi)
            RB=[RB(1:(find(RB=='/'))),'Complex'];
            set_param([block,'/Mode I'],'Referenceblock',RB)

        end
        if~strcmp(get_param([block,'/Iabc'],'Blocktype'),'Terminator')
            replace_block(block,'LookUnderMasks','on','FollowLinks','on','Name','Iabc','Terminator','noprompt');
        end

    end










    set_param(block,'PSBequivalent','0');

