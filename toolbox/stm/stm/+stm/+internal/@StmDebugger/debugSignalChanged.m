function debugSignalChanged(baselineSignal,simOutSignal)





    baselineSignal=str2double(baselineSignal);
    simOutSignal=str2double(simOutSignal);


    stmDebugger=stm.internal.StmDebugger.getInstance;
    assert(~isempty(stmDebugger));

    stmDebugger.updateBaselineSignal(baselineSignal);
    stmDebugger.updateSimOutSignal(simOutSignal);


    stmDebugger.setupSlicerCriteria;
end
