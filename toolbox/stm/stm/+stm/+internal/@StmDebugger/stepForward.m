function stepForward()




    stmDebugger=stm.internal.StmDebugger.getInstance;

    if isempty(stmDebugger)
        return;
    end

    if~isempty(stmDebugger.resultsDebugger)
        stmDebugger.resultsDebugger.stepForward;
    end

end
