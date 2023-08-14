function ResultDescription=checkRapidAcceleratorSignalLogging(system)



    model=bdroot(system);
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);

    ResultDescription={{''};{''}};

    cs=getActiveConfigSet(bdroot(model));
    isRAccel=strcmpi(get_param(model,'SimulationMode'),'rapid-accelerator');
    isSignalLoggingOn=strcmpi(get_param(model,'SignalLogging'),'on');

    if(~isRAccel)
        ResultDescription=DAStudio.message('ModelAdvisor:engine:MACheckRapidAcceleratorSignalLogging_PassNotRapidAccelerator');
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
        return;
    end

    if(isSignalLoggingOn)
        ResultDescription=DAStudio.message('ModelAdvisor:engine:MACheckRapidAcceleratorSignalLogging_PassAlreadyUsing');
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
        return;
    end

    Passed=true;
    mi=Simulink.SimulationData.ModelLoggingInfo.createFromModel(model);
    if(length(mi.Signals)>0)
        Passed=false;
    end

    mdladvObj.setCheckResultStatus(Passed);
    mdladvObj.setActionEnable(~Passed);

    if(Passed)
        ResultDescription=DAStudio.message('ModelAdvisor:engine:MACheckRapidAcceleratorSignalLogging_PassNoSignalLogging');
    else
        ResultDescription=DAStudio.message('ModelAdvisor:engine:MACheckRapidAcceleratorSignalLogging_WarningCanUseSignalLogging');
    end

