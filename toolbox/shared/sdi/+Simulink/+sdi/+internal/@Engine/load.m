function[validSDIMatFile,wasCancelled]=load(this,filename,cmdLineLoad,varargin)










    this.showRunAtTop;

    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    if Simulink.HMI.isSessionSaveOrLoadInProgress()
        error(getString(message('SDI:sdi:MLDATXSaveLoadInProgress')));
    end






    [fileExists,filename]=validateExistence(filename);
    if~fileExists
        error(message('simulation_data_repository:sdr:SessionFileNotFound'));
    end
    [~,~,extension]=fileparts(filename);

    isMldatx=~isempty(extension)&&strcmp(extension,'.mldatx');
    if~isMldatx||cmdLineLoad


        message.publish('/sdi2/progressUpdate',struct('dataIO','begin','appName',appName));
        Simulink.sdi.internal.controllers.SessionSaveLoad.setActionInProgress(appName,true);
        tmp=onCleanup(@()Simulink.sdi.internal.controllers.SessionSaveLoad.updateGUITitleAfterSessionLoad(appName));
        tmp2=onCleanup(@()Simulink.sdi.internal.controllers.SessionSaveLoad.setActionInProgress(appName,false));
        tmp3=onCleanup(@()message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName',appName)));
    end




    Simulink.HMI.initializeWebClient;
    str=getString(message('SDI:sdi:MGLoading'));
    progTracker=[];
    [filepath,shortFilename,extension]=fileparts(filename);




    if isempty(filepath)
        filename=which(filename);
    end
    if strcmp(extension,'.mat')
        isMldatx=0;
        progTracker=Simulink.sdi.ProgressTracker(str,1,true,false);
    end


    [fileVer,filename]=Simulink.sdi.internal.Util.getSDIMatFileVersion(filename);
    validSDIMatFile=fileVer>0;
    if~validSDIMatFile
        if~isempty(progTracker)
            delete(progTracker);
        end
        error(message('SDI:sdi:badMatFile',filename));
    end

    bIsSessionFile=Simulink.sdi.isSessionFile(filename);
    if fileVer>2&&~bIsSessionFile
        error(message('SDI:sdi:InvalidMLDATXFile',filename));
    end


    successFlag=[];
    replot=true;

    if fileVer>1
        try
            this.DiffRunResult=Simulink.sdi.DiffRunResult(0,this);
            if fileVer>2
                if isMldatx






                    setupData=struct;
                    setupData.dataIO='begin';
                    setupData.Msg=getString(message('SDI:sdi:InitializingProgress'));
                    setupData.isMldatx=isMldatx;
                    setupData.filename=shortFilename;
                    setupData.appName=appName;
                    message.publish('/sdi2/progressUpdate',setupData);
                    Simulink.sdi.internal.controllers.SessionSaveLoad.setActionInProgress(appName,true);
                    idx=length(varargin);
                    varargin{idx+1}=appName;
                end

                [successFlag,loaded,replot]=Simulink.sdi.loadSession(filename,cmdLineLoad,varargin{:});
                if~loaded
                    setupData=struct;
                    setupData.dataIO='error';
                    setupData.Msg=getString(message('SDI:sdi:mgError'));
                    setupData.isMldatx=isMldatx;
                    setupData.appName=appName;
                    message.publish('/sdi2/progressUpdate',setupData);
                    Simulink.sdi.internal.controllers.SessionSaveLoad.setActionInProgress(appName,false);
                    return;
                end
                if~isMldatx||cmdLineLoad
                    eng=Simulink.sdi.Instance.engine;
                    runIDs=eng.getAllRunIDs(appName);
                    sigIDs=[];
                    for idx=1:length(runIDs)
                        sigIDs=[sigIDs;eng.getAllSignalIDs(runIDs(idx))];%#ok<AGROW>
                    end
                    if~isempty(sigIDs)
                        Simulink.sdi.SignalClient.publishSignalLabels(sigIDs);

                        saUtil=Simulink.sdi.Instance.getSetSAUtils();
                        if strcmp(appName,'siganalyzer')&&~isempty(saUtil)
                            safeTransaction(eng,@saUtil.updateSASignalIDOnLoad,eng,sigIDs);
                            safeTransaction(eng,@saUtil.updateSASignalHierarchyOnLoad,eng,sigIDs);
                        end
                    end
                end
            else
                this.sigRepository.load(filename,appName);
                saUtil=Simulink.sdi.Instance.getSetSAUtils();
                if strcmp(appName,'siganalyzer')&&~isempty(saUtil)
                    eng=Simulink.sdi.Instance.engine;
                    runIDs=eng.getAllRunIDs(appName);
                    sigIDs=[];
                    for idx=1:length(runIDs)
                        sigIDs=[sigIDs;eng.getAllSignalIDs(runIDs(idx))];%#ok<AGROW>
                    end
                    safeTransaction(eng,@saUtil.updateSALSSRepoAndSignalHierarchyOnLoad,eng,sigIDs,filename,extension);
                end
            end
        catch me %#ok<NASGU>
            validSDIMatFile=false;
            if isMldatx&&~cmdLineLoad




                setupData=struct;
                setupData.dataIO='error';
                setupData.isMldatx=isMldatx;
                setupData.appName=appName;
                message.publish('/sdi2/progressUpdate',setupData);
                Simulink.sdi.internal.controllers.SessionSaveLoad.setActionInProgress(appName,false);
            end
        end
    else
        validSDIMatFile=this.safeTransaction(@helperLoadFile,this,filename);
    end


    if~isempty(progTracker)
        delete(progTracker)
    end

    if~isempty(successFlag)&&successFlag==-1


        wasCancelled=true;
        return;
    else
        wasCancelled=false;
    end

    if~bIsSessionFile
        return;
    end

    if isMldatx&&~cmdLineLoad
        return;
    end

    notify(this,'loadSaveEvent',Simulink.sdi.internal.SDIEvent('loadSaveEvent',replot,appName));
    ctrl=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    ctrl.cacheSessionInfo(...
    strcat(shortFilename,extension),...
    filepath);


    if validSDIMatFile
        this.fileName=filename;
        dirty=false;
        this.dirty=dirty;
        ctrl.setDirty(dirty,true);
    end
end

function validSDIMatFile=helperLoadFile(this,filename)
    try
        validSDIMatFile=this.loadHelper(filename);
    catch me %#ok<NASGU>
        validSDIMatFile=false;
    end
end

function[fileExists,newFileName]=validateExistence(filename)
    [~,~,extension]=fileparts(filename);
    newFileName=filename;
    if any(exist([filename,'.mldatx'],'file'))
        fileExists=true;
        newFileName=[filename,'.mldatx'];
    elseif any(exist([filename,'.mat'],'file'))
        fileExists=true;
        newFileName=[filename,'.mat'];
    elseif~isempty(extension)&&any(exist(filename,'file'))
        fileExists=true;
    else
        fileExists=false;
    end
end


