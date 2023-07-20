function parameterList=getParameters(modelName,harnessName,loadApplicationFrom,targetApplication,targetName)



    stm.internal.genericrealtime.FollowProgress.progress('begin: getParameters()');
    endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: getParameters()'));

    if(slsvTestingHook('STMForceASAMXILRealTimeWorkflow')>=3)
        loadApplicationFrom=slsvTestingHook('STMForceASAMXILRealTimeWorkflow');
    end

    if~stm.internal.genericrealtime.checkxpctarget()&&loadApplicationFrom<=3
        error(message('stm:realtime:RTNotInstalled'));
    end



    needToBuildModel=true;
    isModelLoaded=false;
    isTargetConnected=false;


    [pathstr,targetApplication,~]=fileparts(targetApplication);

    if(exist(pathstr,'dir'))
        addpath(pathstr);
        rp=onCleanup(@()rmpath(pathstr));
        mldatxApplicationPath=[pathstr,'/',targetApplication];
    else

        mldatxApplicationPath=targetApplication;
    end


    persistent lastCheckSum;

    if stm.internal.genericrealtime.isTargetDefined(targetName)
        try
            defaultTarget=stm.internal.genericrealtime.connectToTarget(targetName);
            if~isempty(targetName)&&~strcmpi(defaultTarget,targetName)
                restoreTgt=onCleanup(@()restoreDefaultTarget(defaultTarget));
            else
                tgs=slrealtime.Targets;
                targetName=tgs.getDefaultTargetName;
            end
            isTargetConnected=true;
        catch
            if(loadApplicationFrom==2)
                if isempty(targetName)
                    targetName='Default';
                end
                error(message('stm:realtime:UnableToConnectToTarget',targetName));
            end
        end
    else
        if(loadApplicationFrom==2)
            error(message('stm:realtime:TargetUndefined',targetName));
        end
    end

    cause=[];

    if loadApplicationFrom==0
        stm.internal.genericrealtime.FollowProgress.progress('** Load model/harness **');


        modelIsLoaded=true;
        if~stm.internal.util.SimulinkModel.isModelOpenOrLoaded(modelName)

            modelIsLoaded=false;
            load_system(modelName);
        else
            preserve_dirty=Simulink.PreserveDirtyFlag(modelName,'blockDiagram');%#ok<NASGU>
        end

        [modelToUse,deactivateHarness,currHarness,oldHarness,~,wasHarnessOpen]=stm.internal.util.resolveHarness(modelName,harnessName);
        oc=onCleanup(@()cleanupFunction(modelName,modelIsLoaded,currHarness,deactivateHarness,oldHarness,wasHarnessOpen));













        if needToBuildModel
            stm.internal.genericrealtime.FollowProgress.progress('** Build model/harness **');
            stm.internal.genericrealtime.buildModel(modelToUse);
        end
        try
            targetApplication=[modelToUse,'.mldatx'];
            if~exist(targetApplication,'file')
                error(message('stm:realtime:NoMldatxFileWasCreated'));
            end


            mldatxApplicationPath=which(targetApplication);
            parameterList=stm.internal.genericrealtime.getParametersFromArtifacts(modelName,harnessName,mldatxApplicationPath);
        catch ME
            if~isempty(cause)
                ME=addCause(ME,cause);
            end
            rethrow(ME);
        end
    end

    if loadApplicationFrom==1
        stm.internal.genericrealtime.FollowProgress.progress('** Load model/harness **');
        try
            parameterList=stm.internal.genericrealtime.getParametersFromArtifacts(modelName,harnessName,mldatxApplicationPath);
        catch ME
            if~isempty(cause)
                ME=addCause(ME,cause);
            end
            rethrow(ME);
        end
    end

    if loadApplicationFrom==2

        try
            tgs=slrealtime.Targets;
            tg=tgs.getTarget(targetName);
            mldatxApplicationPath=tg.get('tc').ModelProperties.Application;
            parameterList=stm.internal.genericrealtime.getParametersFromArtifacts(modelName,harnessName,mldatxApplicationPath);
        catch ME
            if~isempty(cause)
                ME=addCause(ME,cause);
            end
            rethrow(ME);
        end
    end
end

function restoreDefaultTarget(defaultTarget)

    target_object=SimulinkRealTime.getTargetSettings(defaultTarget);
    setAsDefaultTarget(target_object);
end

function cleanupFunction(modelName,wasLoaded,currHarness,deactivateHarness,oldHarness,wasHarnessOpen)
    stm.internal.genericrealtime.FollowProgress.progress('** Cleanup  **');

    if~isempty(currHarness)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
        end
    end


    if~wasLoaded
        bdclose(modelName);
    end
end
