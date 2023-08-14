function progTracker=createProgressTrackerForExport(~,varargin)


    progTracker=[];

    fileName=varargin{1};
    runIDs=varargin{2};
    sigIDs=varargin{3};

    if Simulink.sdi.Instance.isSDIRunning()



        totalSignals=locGetTotalNumSignals(runIDs,sigIDs);
        str=getString(message('SDI:sdi:MLDATXWriting',fileName));
        progTracker=Simulink.sdi.ProgressTracker(str,2*totalSignals+1,true);
        progTracker.setTotalSignals(2*totalSignals+1);
    end
end


function totalSignals=locGetTotalNumSignals(runIDs,sigIDs)
    repo=sdi.Repository(1);
    totalSignals=0;


    for idx=1:numel(sigIDs)
        totalSignals=totalSignals+locGetTotalLeafSignals(sigIDs(idx),repo);
    end


    for idx=1:numel(runIDs)
        curSigIDs=repo.getAllSignalIDs(runIDs(idx),'leaf');
        totalSignals=totalSignals+numel(curSigIDs);
    end
end

function ret=locGetTotalLeafSignals(sigID,repo)
    ret=0;
    childIDs=repo.getSignalChildren(sigID);
    if isempty(childIDs)
        ret=ret+1;
    else
        for idx=1:numel(childIDs)
            ret=ret+locGetTotalLeafSignals(childIDs(idx),repo);
        end
    end
end
