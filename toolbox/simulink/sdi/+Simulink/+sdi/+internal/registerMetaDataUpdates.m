function registerMetaDataUpdates(eng)
    if~eng.IsMetaDataUpdateRegistered&&is_simulink_loaded
        slInternal(...
        'registerSimMetadataCallback',...
        'SDI_CALLBACK',...
        @(x)locOnMetaDataUpdate(x));
        eng.IsMetaDataUpdateRegistered=true;
    end
end


function locOnMetaDataUpdate(md)
    mdl=md.ModelInfo.ModelName;


    runID=Simulink.sdi.getCurrentRunID(mdl);


    compileSucceeded=isempty(md.ExecutionInfo.ErrorDiagnostic)||...
    ~strcmp(md.ExecutionInfo.ErrorDiagnostic.SimulationPhase,'Initialization');


    if runID&&compileSucceeded
        Simulink.sdi.internal.import.SimulationOutputParser.setMetaDataForRun(md,runID);
    end
end
