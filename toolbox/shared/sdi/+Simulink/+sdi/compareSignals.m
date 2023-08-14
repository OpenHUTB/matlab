function diff=compareSignals(signalID1,signalID2)





    engine=Simulink.sdi.Instance.engine;
    [~,comparisonSignalID1,comparisonSignalID2]=Simulink.sdi.internal.compareSignalsAndAddToRun(...
    engine.sigRepository,signalID1,signalID2,[]);
    diff1=Simulink.sdi.DiffSignalResult.empty;
    diff2=Simulink.sdi.DiffSignalResult.empty;
    if comparisonSignalID1
        diff1=Simulink.sdi.DiffSignalResult(comparisonSignalID1,engine);
    end
    if comparisonSignalID2
        diff2=Simulink.sdi.DiffSignalResult(comparisonSignalID2,engine);
    end
    diff=[diff1,diff2];
end