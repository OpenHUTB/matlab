function mldatxLoadComplete(fstem,fpath,dirtyBit,replot,signalHierarchyFlag,varargin)

    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName',ctrlObj.AppName));

    if~Simulink.sdi.isSessionFile(fstem)||~Simulink.sdi.isSessionFile(fullfile(fpath,fstem))
        return;
    end

    ctrlObj.ActionInProgress=false;
    ctrlObj.cacheSessionInfo(...
    fstem,...
    fpath,...
    dirtyBit);
    eng=Simulink.sdi.Instance.engine;
    runIDs=eng.getAllRunIDs(ctrlObj.AppName);
    sigIDs=[];
    for idx=1:length(runIDs)
        sigIDs=[sigIDs;eng.getAllSignalIDs(runIDs(idx))];%#ok<AGROW>
    end

    if~isempty(sigIDs)



        saUtil=Simulink.sdi.Instance.getSetSAUtils();
        if strcmp(appName,'siganalyzer')&&~isempty(saUtil)
            safeTransaction(eng,@saUtil.updateSASignalIDOnLoad,eng,sigIDs);

            if~signalHierarchyFlag
                safeTransaction(eng,@saUtil.updateSASignalHierarchyOnLoad,eng,sigIDs)
            end
        end
        Simulink.sdi.SignalClient.publishSignalLabels(sigIDs);
    end

    ctrlObj.Engine.publishUpdateLabelsNotification();
    notify(ctrlObj.Engine,'loadSaveEvent',Simulink.sdi.internal.SDIEvent('loadSaveEvent',replot,appName));


    Simulink.sdi.internal.controllers.SessionSaveLoad.updateGUITitleAfterSessionLoad(appName);
end