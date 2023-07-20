function onSignalsRemoved(this,varargin)
    assert(length(varargin)>=3);
    runID=varargin{1};
    sigIDs=varargin{2};
    checkedIDs=varargin{3};

    bUpdateTable=true;
    if numel(varargin)>3
        bUpdateTable=varargin{4};
    end

    deletedRuns=int32.empty();
    appName='sdi';

    deletedSignals=repmat(struct('signalID',0,'parentRunID',runID),size(sigIDs));
    for idx=1:numel(sigIDs)
        deletedSignals(idx).signalID=sigIDs(idx);
    end


    if bUpdateTable
        evtType='runsAndSignalsDeleteEvent';
        notify(...
        this.Engine_,...
        evtType,...
        Simulink.sdi.internal.SDIEvent(evtType,sigIDs,appName,deletedRuns,deletedSignals));
    end


    idsToClear=locGetUniqueCheckedSignals(sigIDs,checkedIDs);
    if~isempty(idsToClear)
        Simulink.sdi.clearSignalsFromCanvas(sigIDs);
    end


    this.Engine_.dirty=true;
end


function ret=locGetUniqueCheckedSignals(sigIDs,checkedIDs)
    ret=int32.empty();
    for idx=1:numel(checkedIDs)
        if any(sigIDs==checkedIDs(idx))
            ret(end+1)=int32(checkedIDs(idx));%#ok<AGROW> 
        end
    end
end