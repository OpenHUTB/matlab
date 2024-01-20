function isValid=isValidRunID(runID)
    isValid=Simulink.sdi.Instance.engine.isValidRunID(runID);
end