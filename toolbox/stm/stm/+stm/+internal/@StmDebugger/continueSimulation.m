function continueSimulation(buttonState)




    stmDebugger=stm.internal.StmDebugger.getInstance;

    if isempty(stmDebugger)
        return;
    end

    switch buttonState
    case 'run'
        stmDebugger.resultsDebugger.runSimulation;
    case 'continue'
        stmDebugger.resultsDebugger.continueSimulation;

    end

end
