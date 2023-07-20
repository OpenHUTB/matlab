function[needsRTWArtifacts,...
    isRunningXILSimForProtectedModel,...
    isRunningSILSimForProtectedModel,...
    isRunningPILSimForProtectedModel]=...
    buildNeedsRTWArtifacts(isDoingSimForRTWBuild,modelReferenceTargetType,protectedMdlRefSimModes)





    if~iscell(protectedMdlRefSimModes)
        protectedMdlRefSimModes={protectedMdlRefSimModes};
    end


    isRunningSILSimForProtectedModel=ismember(Simulink.ModelReference.internal.SimulationMode.SimulationModeSIL,protectedMdlRefSimModes);
    isRunningPILSimForProtectedModel=ismember(Simulink.ModelReference.internal.SimulationMode.SimulationModePIL,protectedMdlRefSimModes);
    isRunningXILSimForProtectedModel=isRunningSILSimForProtectedModel||...
    isRunningPILSimForProtectedModel;


    needsRTWArtifacts=isDoingSimForRTWBuild||...
    isRunningXILSimForProtectedModel||...
    strcmp(modelReferenceTargetType,'RTW');
end


