function loadMldatx(mldatxFileName)




    if isempty(mldatxFileName)
        error(message('stm:realtime:EmptyMldatxFile'));
    end

    [pathstr,mldatxName,~]=fileparts(mldatxFileName);

    if(exist(pathstr,'dir'))
        mldatxApplicationPath=fullfile(pathstr,mldatxName);
    else

        mldatxApplicationPath=mldatxName;
    end

    mldatxExtName=[mldatxApplicationPath,'.mldatx'];
    if exist(mldatxExtName,'file')


        fullPathMldatxToMldatx=which(mldatxExtName);
        if~isempty(fullPathMldatxToMldatx)

            [p,d,~]=fileparts(fullPathMldatxToMldatx);
            mldatxApplicationPath=fullfile(p,d);
        end
    end


    if~exist([mldatxApplicationPath,'.mldatx'],'file')
        error(message('stm:realtime:InvalidMldatxFile',mldatxName));
    end

    tg=slrealtime;


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
        tg.load(mldatxApplicationPath);
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


end
