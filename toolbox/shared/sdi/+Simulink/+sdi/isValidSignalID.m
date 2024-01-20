function isValid=isValidSignalID(signalID)
    isValid=Simulink.sdi.Instance.engine.isValidSignalID(signalID);
end