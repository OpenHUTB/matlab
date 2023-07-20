function deletedAllRuns=deleteRunWithoutNotifyingTable(this,runID)
    signalIDsToClear=...
    this.getAllSignalIDs(int32(runID),'checked');

    this.sigRepository.removeRun(runID);
    this.dirty=true;
    if(this.getRunCount()==0)
        this.deleteAllRuns('allSDI','suppressNotification');
        deletedAllRuns=true;
    else
        deletedAllRuns=false;
    end

    if~isempty(signalIDsToClear)
        Simulink.sdi.clearSignalsFromCanvas(signalIDsToClear);
    end
end