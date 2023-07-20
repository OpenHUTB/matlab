function onRunsCreated(~,varargin)

    runIDs=varargin{1};
    notifyFlag=varargin{2};
    appName=varargin{3};
    runName=varargin{4};
    eng=Simulink.sdi.Instance.engine;


    if~isempty(runIDs)
        Simulink.sdi.internal.controllers.SessionSaveLoad.setDirtyFlag(true,'appName',appName);
        eng.newRunIDs=runIDs;
        eng.updateFlag=runName;
    end


    if notifyFlag
        for idx=1:numel(runIDs)
            notify(eng,'runAddedEvent',Simulink.sdi.internal.SDIEvent('runAddedEvent',runIDs(idx)));
        end
    end


    if~isempty(runIDs)
        Simulink.sdi.internal.pushRunMetaDataFromWorker();
    end
end
