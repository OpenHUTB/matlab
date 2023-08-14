function runToFailure(timeOfFailure)




    stmDebugger=stm.internal.StmDebugger.getInstance;

    if isempty(stmDebugger)
        return;
    end

    if~isempty(stmDebugger.resultsDebugger)
        stmDebugger.resultsDebugger.runToTimeStep(timeOfFailure+stmDebugger.timeDiff);
    end

end
