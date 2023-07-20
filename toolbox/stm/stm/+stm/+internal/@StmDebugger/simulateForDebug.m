function simOut=simulateForDebug(runTestCfg,simWatcher)



    import stm.internal.SlicerDebuggingStatus;

    model=runTestCfg.modelToRun;
    stmDebugger=stm.internal.StmDebugger.getInstance;
    stmDebugger.ModelName=model;
    stmDebugger.simWatcher=simWatcher;
    stmDebugger.addModelCloseCallBack;


    open_system(model);
    try
        stmDebugger.resultsDebugger=SlicerApplication.SimulationResultDebugger(runTestCfg.SimulationInput);
        stmDebugger.resultsDebugger.setTimeWindowChangeCb(@stm.internal.slicerTimeWindowCb,stmDebugger.timeDiff);
        stmDebugger.addSlicerCloseCallback;
        stmDebugger.addSlicerStepHighlightCompletedListener;
        simOut=stmDebugger.resultsDebugger.simulateForCoverage();
        stmDebugger.switchToSimulationTab;
    catch Mex

        stm.internal.setSlicerDebugStatus(uint32(SlicerDebuggingStatus.DebugInactive));

        stmDebugger.tearDownSession;
        rethrow(Mex);
    end
end
