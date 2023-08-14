function[wasModelChanged,oReason,oBSCause]=checkIfModelWasChangedUsingSimInput(model,targetShortName,buildArgs,binfo_cache)



    wasModelChanged=false;
    oReason='';
    oBSCause='';

    modelWorkspaceChangedUsingSimInput=any(strcmp(buildArgs.SimulationInputInfo.ModelWorkspaceNames,model));
    if modelWorkspaceChangedUsingSimInput||binfo_cache.modelWorkspaceChangedUsingSimInput
        wasModelChanged=true;
        oReason=DAStudio.message(...
        'Simulink:slbuild:modelWorkspaceChanged',...
        targetShortName,model);
        oBSCause=DAStudio.message(...
        'Simulink:slbuild:bsModelWorkspaceChanged',model);
        return;
    end

    signalLoggingChangedUsingSimInput=any(strcmp(buildArgs.SimulationInputInfo.ModelsModifiedForLogging,model));
    if signalLoggingChangedUsingSimInput||binfo_cache.signalLoggingChangedUsingSimInput
        wasModelChanged=true;
        oReason=DAStudio.message(...
        'Simulink:slbuild:loggedSignalsChanged',...
        targetShortName,model);
        oBSCause=DAStudio.message(...
        'Simulink:slbuild:bsLoggedSignalsChanged',model);
        return;
    end
end
