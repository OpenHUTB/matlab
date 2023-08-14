function validateWizardCUTStepInput(components,topModelName,isInBatchMode)
    components=string(components);
    topModelName=string(topModelName);
    createForTopModel=any(components==topModelName);
    if createForTopModel&&bdIsLibrary(topModelName)&&~isInBatchMode
        error(message('stm:TestForSubsystem:TestForLibraryMdlNotSupported'));
    end
    stm.internal.TestForSubsystem.validateAndConvertSubsystemInputToStrings(components,true);
    stm.internal.TestForSubsystem.validateTopModelInput(topModelName,components,isInBatchMode,components);
    stm.internal.TestForSubsystem.validateSimulinkObjsAndMRHierarchy(topModelName,components,true);
end

