function handleRunAppMoved(runID,curApp)


    eng=Simulink.sdi.Instance.engine;
    [uniqueDbIDs,runIDs,signalsIDInfo]=eng.sigRepository.getUniqueRunAndSignalIDs(runID);
    signalIDsToClear=eng.sigRepository.getCheckedSignalsFromDbIDs(uniqueDbIDs);


    if strcmpi(curApp,'SDIComparison')
        eng.DiffRunResult=Simulink.sdi.DiffRunResult(0,eng);
    end


    if~isempty(signalIDsToClear)
        Simulink.sdi.clearSignalsFromCanvas(signalIDsToClear);
    end


    notify(eng,...
    'runsAndSignalsDeleteEvent',...
    Simulink.sdi.internal.SDIEvent('runsAndSignalsDeleteEvent',uniqueDbIDs,curApp,runIDs,signalsIDInfo));
    notify(eng,'loadSaveEvent');
end