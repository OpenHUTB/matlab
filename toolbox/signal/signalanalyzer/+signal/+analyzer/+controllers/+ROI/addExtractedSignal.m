function addExtractedSignal(runIDs,signalIDs)








    eng=Simulink.sdi.Instance.engine;


    if(~isempty(runIDs)&&~isempty(signalIDs))
        safeTransaction(eng,@handleROITransaction,runIDs,signalIDs);
    end


    if signal.analyzer.Instance.isSDIRunning()
        Simulink.sdi.internal.controllers.SessionSaveLoad.setDirtyFlag(true,'appName','siganalyzer');
    end


    message.publish('/sdi2/signalCreationCompleted','');
end


function handleROITransaction(runIDs,signalIDs)

    signal.analyzer.SignalUtilities.updateResampledSignal(signalIDs);

    runIDs=unique(runIDs);
    for idx=1:length(runIDs)
        runID=runIDs(idx);
        signal.analyzer.SignalUtilities.notifySignalsInsertedEvent(runID);
    end
end
