function debugButtonClicked(sigId,simIndex,timeDiff)





    if isa(sigId,'double')
        signalId=sigId;
    else
        signalId=str2double(sigId);
    end

    if~isa(timeDiff,'double')
        timeDiff=str2double(timeDiff);
    end


    stmDebugger=stm.internal.StmDebugger.getInstance;

    if~isempty(stmDebugger)&&isvalid(stmDebugger)
        return;
    end


    stmDebugger=stm.internal.StmDebugger.getInstance(signalId,timeDiff);

    stmDebugger.simulationToDebug=simIndex;

    stmDebugger.timeDiff=timeDiff;
end
