function stepBack()




    stmDebugger=stm.internal.StmDebugger.getInstance;

    if isempty(stmDebugger)
        return;
    end

    if~isempty(stmDebugger.resultsDebugger)
        stmDebugger.resultsDebugger.stepBack;
    end

end
