function setRunName(this,runID,runName)
    if isnumeric(runName)
        runName=num2str(runName);
    end
    this.sigRepository.setRunName(runID,runName);
    runName=this.getRunName(runID);
    this.dirty=true;

    notify(this,'treeRunPropertyEvent',...
    Simulink.sdi.internal.SDIEvent('treeRunPropertyEvent',...
    runID,runName,'runName'));

    sigIDs=this.getAllSignalIDs(runID,'leaf');
    Simulink.sdi.SignalClient.publishSignalLabels(sigIDs);
end