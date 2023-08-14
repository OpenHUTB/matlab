function runID=createRunOrAddToStreamedRun(mdl,runName,varNames,varValues)









    if nargin>0
        mdl=convertStringsToChars(mdl);
    end

    if nargin>1
        runName=convertStringsToChars(runName);
    end

    if nargin>2
        if isstring(varNames)
            varNames=cellstr(varNames);
        end
    end


    Simulink.sdi.internal.flushStreamingBackend();


    eng=Simulink.sdi.Instance.engine();
    runID=eng.getCurrentStreamingRunID(mdl);


    if runID
        addToRunFromNamesAndValues(eng,runID,varNames,varValues,mdl);
        notify(eng,'signalsInsertedEvent',Simulink.sdi.internal.SDIEvent('signalsInsertedEvent',runID));
        setRunName(eng,runID,runName);
    else
        runID=Simulink.sdi.createRun(runName,'namevalue',varNames,varValues);
    end
end
