
function hasNonDefaultSync=updateBaselineSignal(baselineFile,signalId,sheet,range)



    engine=Simulink.sdi.Instance.engine;
    signal=engine.getSignal(signalId);
    startTime=signal.DataValues.Time(1);
    stopTime=signal.DataValues.Time(end);
    hasNonDefaultSync=stm.internal.util.updateBaselineSignalRegion(baselineFile,signalId,...
    startTime,stopTime,sheet,range);
end
