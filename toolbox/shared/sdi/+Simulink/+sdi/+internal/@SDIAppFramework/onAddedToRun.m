function onAddedToRun(~,varargin)

    runIDs=varargin{1};
    eng=Simulink.sdi.Instance.engine;


    if length(runIDs)>1
        appsAsStrings={};
        appsAsStrings{end+1}=eng.sigRepository.getRunAppAsString(runIDs(1));
        appName=appsAsStrings{1};
        Simulink.sdi.loadSDIEvent(appName);
        notify(eng,'loadSaveEvent',Simulink.sdi.internal.SDIEvent('loadSaveEvent',true,appName));
    end


    eng.dirty=true;
end
