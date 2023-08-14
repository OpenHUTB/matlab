function ic=getSynchronousMachineInitialConditions(blockName)





    import ee.internal.mask.getValue;


    if getValue(blockName,'initialization_option','1')~=1

        baseValues=ee.internal.mask.getSynchronousMachineAssociatedBases(blockName);
        b=baseValues.b;
        rc=baseValues.rc;
        fd=baseValues.fd;


        f=ee.internal.mask.getSynchronousMachineParametersFundamental(blockName);


        ic=ee.internal.machines.createEmptySynchronousInitialConditions();

        if getValue(blockName,'initialization_option','1')==2


            ic.si_Vmag0=getValue(blockName,'Vmag0','V');
            ic.si_Vang0=getValue(blockName,'Vang0','rad');
            ic.si_Pt0=getValue(blockName,'Pt0','V*A');
            ic.si_Qt0=getValue(blockName,'Qt0','V*A');

        else
            modelName=bdroot(blockName);



            simscapeLogName=get_param(modelName,'SimscapeLogName');
            simscapeLogType=get_param(modelName,'SimscapeLogType');
            logSimulationType=get_param(blockName,'LogSimulationData');
            returnWorkspaceOutputs=get_param(modelName,'ReturnWorkspaceOutputs');

            switch simscapeLogType
            case 'all'

            case 'local'

                set_param(blockName,'LogSimulationData','on');
            case 'none'

                set_param(modelName,'SimscapeLogType','local');
                set_param(blockName,'LogSimulationData','on');
            otherwise
                warning('SimcapeLogType set to unknown value');
            end

            if strcmp(returnWorkspaceOutputs,'on')
                set_param(modelName,'ReturnWorkspaceOutputs','off');
            end

            modelNameString=get_param(modelName,'Name');

            evalin('base',['sim(''',modelNameString,''',[0 0]);']);
            simlog=evalin('base',simscapeLogName);
            synchronousMachineSimulationData=simscape.logging.findNode(simlog,blockName);


            if getValue(blockName,'source_type','1')==1
                ic.si_Vang0=getValue(blockName,'Vang0','rad');
            else
                ic.si_Vang0=synchronousMachineSimulationData.ic_terminal_phase.series.values*(pi/180);
            end
            ic.si_Vmag0=synchronousMachineSimulationData.ic_pu_terminal_voltage.series.values*b.VRated;
            ic.si_Pt0=synchronousMachineSimulationData.ic_real_power_generated.series.values;
            ic.si_Qt0=synchronousMachineSimulationData.ic_reactive_power_generated.series.values;


            set_param(modelName,'SimscapeLogType',simscapeLogType);
            set_param(blockName,'LogSimulationData',logSimulationType);
            set_param(modelName,'ReturnWorkspaceOutputs',returnWorkspaceOutputs);
        end

        ic=ee.internal.machines.updateSynchronousInitialConditions(ic,b,f);
        ic=ee.internal.machines.updateSynchronousAssociatedInitialConditions(ic,b,f,rc,fd);

    else

        ic=ee.internal.machines.createEmptySynchronousInitialConditions();
    end

end
