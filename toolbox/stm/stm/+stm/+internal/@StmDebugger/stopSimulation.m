function stopSimulation()




    stmDebugger=stm.internal.StmDebugger.getInstance;

    if isempty(stmDebugger)
        return;
    end

    if~isempty(stmDebugger.resultsDebugger)
        stmDebugger.resultsDebugger.stopSimulation;
    end

end
