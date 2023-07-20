function compData=exportComparisonData(this,signalID)







    eng=Simulink.sdi.Instance.engine;
    [baselineID,compareToID,~,toleranceID,~,~,~,~,compMinusBaseID]=...
    eng.getSignalComparisonResultByType(signalID);
    compData=Simulink.SimulationData.Signal();
    compData.Name=eng.getSignalLabel(signalID);
    compData.BlockPath=this.getSignalBlockSource(signalID,true);
    compData.Values.Baseline=this.exportSignalToTimeSeries(baselineID);
    compData.Values.CompareTo=this.exportSignalToTimeSeries(compareToID);
    compData.Values.Difference=this.exportSignalToTimeSeries(compMinusBaseID);
    compData.Values.Tolerance=this.exportSignalToTimeSeries(toleranceID);
end