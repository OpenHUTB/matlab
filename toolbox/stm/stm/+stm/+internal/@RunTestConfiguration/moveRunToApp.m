function moveRunToApp(runID)


    engine=Simulink.sdi.Instance.engine;
    engine.safeTransaction(@helperMoveRunToApp,runID);
end

function helperMoveRunToApp(streamedRunID)
    import stm.internal.RunTestConfiguration;
    [sigs,plotIndices]=RunTestConfiguration.getCheckedSignals(streamedRunID);
    Simulink.sdi.internal.moveRunToApp(streamedRunID,'stm',true);
    RunTestConfiguration.setCheckedSignals(sigs,plotIndices);
end
