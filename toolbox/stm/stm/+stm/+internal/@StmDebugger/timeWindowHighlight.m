function timeWindowHighlight(start,stop)




    stmDebugger=stm.internal.StmDebugger.getInstance;
    assert(~isempty(stmDebugger));
    model=stmDebugger.ModelName;

    modelStartTime=str2double(get_param(model,'StartTime'));
    modelStopTime=str2double(get_param(model,'StopTime'));

    start=start+stmDebugger.timeDiff;
    stop=stop+stmDebugger.timeDiff;

    if(start>=modelStartTime&&stop<=modelStopTime)
        stmDebugger.resultsDebugger.setTimeWindow(start,stop);
    end
end
