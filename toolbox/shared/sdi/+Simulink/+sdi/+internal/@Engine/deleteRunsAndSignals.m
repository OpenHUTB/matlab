function deleteRunsAndSignals(this,dbIDs,appStr,varargin)







    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});

    [uniqueDbIDs,runIDs,signalsIDInfo]=this.sigRepository.getUniqueRunAndSignalIDs(dbIDs);
    signalIDsToClear=this.sigRepository.getCheckedSignalsFromDbIDs(uniqueDbIDs);
    if strcmpi(appStr,'SDIComparison')&&~isempty(runIDs)

        this.DiffRunResult=Simulink.sdi.DiffRunResult(0,this);
    end
    if~isempty(varargin)
        deleteEmptyRun=varargin{1};
    else
        deleteEmptyRun=false;
    end


    this.sigRepository.deleteRunsAndSignals(uniqueDbIDs,deleteEmptyRun);
    if~isempty(signalIDsToClear)
        Simulink.sdi.clearSignalsFromCanvas(signalIDsToClear);
    end
    this.dirty=true;

    if(this.getRunCount(appName)==0)
        this.updateFlag=int32(0);
        this.engineViewsData=[];

        this.runNumByRunID=Simulink.sdi.Map(int32(0),int32(0));
        notify(this,'clearSDIEvent',...
        Simulink.sdi.internal.SDIEvent('clearSDIEvent',appStr));
    else
        notify(this,'runsAndSignalsDeleteEvent',...
        Simulink.sdi.internal.SDIEvent('runsAndSignalsDeleteEvent',...
        uniqueDbIDs,appStr,runIDs,signalsIDInfo));
    end


    this.publishUpdateLabelsNotification();
end
