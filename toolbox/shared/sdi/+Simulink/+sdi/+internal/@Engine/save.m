function wasCancelled=save(this,filename,thumbnailURL,cmdLineSave,varargin)




    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    dirty=Simulink.sdi.getDirtyFlag(appName);


    if~dirty&&(this.isSignalCountZero()||this.getRunCount(appName)==0)
        Simulink.sdi.internal.warning(message('SDI:sdi:NoData'));
        wasCancelled=true;
        return;
    end


    doAllPendingLazyImport(this);

    [~,~,extension]=fileparts(filename);
    isMldatx=~isempty(extension)&&strcmp(extension,'.mldatx');
    ctrl=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    appName=ctrl.AppName;
    if~isMldatx||cmdLineSave


        message.publish('/sdi2/progressUpdate',struct('dataIO','begin','appName',appName));
        Simulink.sdi.internal.controllers.SessionSaveLoad.setActionInProgress(appName,true);
        tmp=onCleanup(@()message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName',appName)));
        tmp2=onCleanup(@()onCleanup(@()Simulink.sdi.internal.controllers.SessionSaveLoad.setActionInProgress(appName,false)));
    end
    Simulink.HMI.synchronouslyFlushWorkerQueue();
    Simulink.HMI.initializeWebClient;
    wasCancelled=false;


    successFlag=[];
    if isMldatx
        try
            if~cmdLineSave






                message.publish('/sdi2/progressUpdate',struct('dataIO','begin','appName',appName));
                Simulink.sdi.internal.controllers.SessionSaveLoad.setActionInProgress(appName,true);
            end
            successFlag=Simulink.sdi.saveSession(appName,filename,thumbnailURL,cmdLineSave,varargin{:});
        catch me
            if isMldatx&&~cmdLineSave




                message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName',appName));
                Simulink.sdi.internal.controllers.SessionSaveLoad.setActionInProgress(appName,false);
            end
            rethrow(me);
        end
    else
        this.sigRepository.save(filename,'web_client');
    end


    Simulink.AsyncQueue.DataType.clearCache();

    if~isempty(successFlag)&&successFlag==-1


        wasCancelled=true;
        return;
    end

    dirtyFlag=false;
    if~isMldatx||cmdLineSave
        if~isempty(varargin)

            dirtyFlag=true;
        end
    end



    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    [pathname,shortFilename,extension]=fileparts(filename);
    ctrlObj.cacheSessionInfo([shortFilename,extension],pathname,dirtyFlag);
    ctrlObj.updateGUITitle();
end

