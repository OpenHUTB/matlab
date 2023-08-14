function appName=loadMldatxFromTarget()


    appName='';
    tg=slrealtime;
    mldatxName=tg.getLastApplication;
    if isempty(mldatxName)||strcmp(mldatxName,'0')
        error(message('stm:realtime:NoApplicationStoredOnTarget'));
    end


    targetSettings=tg.TargetSettings;
    targetName=targetSettings.name;


    if~(tg.isConnected)
        error(message('stm:realtime:UnableToConnectToTarget',targetName));
    end

    if(strcmpi(tg.status,'running'))
        error(message('stm:realtime:TargetIsAlreadyRunningAnApplication',mldatxName,targetName,tg.get('tc').ModelProperties.Application));
    end

    loadingError=[];
    try
        tg.load(mldatxName);
    catch ME
        loadingError=ME;
    end


    if~(tg.isConnected)
        ME=MException(message('stm:realtime:FailedLoadingMldatx',mldatxName,targetName));

        Cause=MException(message('stm:realtime:UnableToConnectToTarget',targetName));

        if~isempty(loadingError)
            ME=addCause(ME,loadingError);
        end
        ME=addCause(ME,Cause);
        throw(ME);
    end


    loadedApp=tg.get('tc').ModelProperties.Application;
    if~strcmpi(loadedApp,mldatxName)
        loadME=MException(message('stm:realtime:LoadMldatxError',mldatxName,loadedApp));
        if~isempty(loadingError)

            loadME=addCause(loadME,loadingError);
        end

        ME=MException(message('stm:realtime:FailedLoadingMldatx',mldatxName,targetName));
        ME=addCause(ME,loadME);
        throw(ME);
    end

    appName=loadedApp;


end
