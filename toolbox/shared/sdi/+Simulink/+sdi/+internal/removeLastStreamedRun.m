function removeLastStreamedRun(mdl)

    eng=Simulink.sdi.Instance.engine();
    runID=eng.getCurrentStreamingRunID(mdl);
    if runID
        Simulink.sdi.deleteRun(runID);
    end
end
