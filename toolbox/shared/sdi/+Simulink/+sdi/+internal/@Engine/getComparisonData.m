function rootData=getComparisonData(this,runID)






    rootData=Simulink.SimulationData.Dataset;
    eng=Simulink.sdi.Instance.engine;
    topSignals=eng.getAllSignalIDs(runID,'top');
    for i=1:length(topSignals)
        comparisonData=this.exportComparisonData(topSignals(i));
        rootData=rootData.addElement(comparisonData);
    end
end