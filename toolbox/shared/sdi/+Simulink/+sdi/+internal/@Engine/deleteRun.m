function deleteRun(this,runID)
    runApp=this.sigRepository.getRunApp(int32(runID));
    if(runApp==2)
        this.DiffRunResult=Simulink.sdi.DiffRunResult(0,this);
    end

    deletedAllRuns=this.deleteRunWithoutNotifyingTable(runID);
    if deletedAllRuns
        this.DiffRunResult=Simulink.sdi.DiffRunResult(0,this);
        notify(this,'clearSDIEvent',...
        Simulink.sdi.internal.SDIEvent('clearSDIEvent','allSDI'));
    else
        this.removeDeletedRunFromTreeTable(runID,runApp);
    end
end