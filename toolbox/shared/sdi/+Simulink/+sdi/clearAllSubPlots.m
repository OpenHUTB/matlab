function clearAllSubPlots(varargin)

    eng=Simulink.sdi.Instance.engine();
    [appName,~]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    safeTransaction(eng,@locClearPlots,eng,appName);
end


function locClearPlots(eng,appName)
    if strcmp(appName,'sdi')
        sigIDs=eng.sigRepository.getAllCheckedSignals();
    else
        sigIDs=eng.sigRepository.getAllCheckedSignals(appName);
    end

    for idx=1:length(sigIDs)
        eng.setSignalCheckedPlots(sigIDs(idx),0);
        notify(eng,'treeSignalPropertyEvent',...
        Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',sigIDs(idx),false,'checked'));
    end
    Simulink.sdi.clearSignalsFromCanvas(sigIDs);
end
