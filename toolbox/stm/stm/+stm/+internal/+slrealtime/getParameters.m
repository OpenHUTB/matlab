function parameterList=getParameters(modelName,harnessName,loadApplicationFrom,targetApplication,targetName)


    if~stm.internal.slrealtime.checkxpctarget()
        error(message('stm:realtime:RTNotInstalled'));
    end

    stm.internal.slrealtime.FollowProgress.progress('-- Start: get real time parameters --');

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

    if stm.internal.slrealtime.isTargetDefined(targetName)
        try
            defaultTarget=stm.internal.slrealtime.connectToTarget(targetName);
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
        stm.internal.slrealtime.FollowProgress.progress('** Load model/harness **');


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
            stm.internal.slrealtime.FollowProgress.progress('** Build model/harness **');
            stm.internal.slrealtime.buildModel(modelToUse);
        end
        try
            targetApplication=[modelToUse,'.mldatx'];
            if~exist(targetApplication,'file')
                error(message('stm:realtime:NoMldatxFileWasCreated'));
            end


            mldatxApplicationPath=which(targetApplication);
            parameterList=getParameterFromArtifacts(modelName,harnessName,mldatxApplicationPath);
        catch ME
            if~isempty(cause)
                ME=addCause(ME,cause);
            end
            rethrow(ME);
        end
    end

    if loadApplicationFrom==1
        stm.internal.slrealtime.FollowProgress.progress('** Load model/harness **');
        try
            parameterList=getParameterFromArtifacts(modelName,harnessName,mldatxApplicationPath);
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
            parameterList=getParameterFromArtifacts(modelName,harnessName,mldatxApplicationPath);
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

function parameterList=getParameterFromArtifacts(modelName,harnessName,targetApplication)
    stm.internal.slrealtime.FollowProgress.progress('** Get parameters from target **');
    appObj=slrealtime.Application(targetApplication);
    slrtParams=appObj.getParameters;
    nParams=length(slrtParams);
    topModel=getTopModel(modelName,harnessName);
    getRuntimeValue=true;
    tg=slrealtime;
    try
        if(tg.isConnected)
            tg.load(targetApplication);
        else
            getRuntimeValue=false;
        end
    catch
        getRuntimeValue=false;
    end
    parameterList=repmat(struct('Name','',...
    'ModelName','',...
    'SourceType','',...
    'ModelElement','',...
    'Value','',...
    'HarnessName','',...
    'ValueType','',...
    'Source','',...
    'SIDFullString','',...
    'IsMask','',...
    'TopModel',''),nParams,1);
    nTotalReturns=1;

    for blkItrIndex=1:nParams
        parameterName=slrtParams(blkItrIndex).BlockParameterName;
        modelElement=slrtParams(blkItrIndex).BlockPath;
        source='';
        if~isempty(modelElement)
            srcSplit=split(modelElement,'/');
            if numel(srcSplit)>1
                source=char(join(srcSplit(2:end)));
            end
        end
        parameterList(nTotalReturns).Name=parameterName;
        parameterList(nTotalReturns).ModelName=modelName;
        parameterList(nTotalReturns).HarnessName=harnessName;
        parameterList(nTotalReturns).TopModel=topModel;
        parameterList(nTotalReturns).SourceType='real-time application';
        if isempty(modelElement)
            [~,modelToUse,~]=fileparts(targetApplication);
            parameterList(nTotalReturns).ModelElement={modelToUse};
        else
            parameterList(nTotalReturns).ModelElement={modelElement};
        end
        parameterList(nTotalReturns).Source=source;
        parameterList(nTotalReturns).SIDFullString='';
        parameterList(nTotalReturns).IsMask=false;
        parameterList(nTotalReturns).Users='';
        parameterList(nTotalReturns).RuntimeValue='';
        parameterList(nTotalReturns).ValueType=1;
        if(getRuntimeValue)
            try
                if~isempty(modelElement)
                    val=tg.getparam(modelElement,parameterName);
                else
                    val=tg.getparam('',parameterName);
                end
                parameterList(nTotalReturns).RuntimeValue=val;
                [canShow,rows,columns,parameterList(nTotalReturns).Value]=getDisplayValue(val);
                if((max(rows,columns)==1&&canShow))
                    parameterList(nTotalReturns).ValueType=0;
                else
                    parameterList(nTotalReturns).ValueType=1;
                end
            catch
            end
        end
        nTotalReturns=nTotalReturns+1;
    end
    status=true;
end

function topModel=getTopModel(model,harness)
    ind=strfind(harness,'%%%');
    if isempty(ind)
        topModel=model;
    else
        topModel=harness(1:ind-1);
    end
end


function[canShow,rows,columns,displayText]=getDisplayValue(runtimeValue)
    [rows,columns]=size(runtimeValue);
    numElements=rows*columns;
    MAX_SIZE=10;

    canShow=isnumeric(runtimeValue)||islogical(runtimeValue)||issparse(runtimeValue);

    if(canShow&&numElements<=MAX_SIZE)
        if(issparse(runtimeValue))
            runtimeValue=full(runtimeValue);
        end
        displayText=mat2str(runtimeValue);
    elseif(ischar(runtimeValue))
        displayText=runtimeValue;
    else
        valueType=class(runtimeValue);
        displayText=sprintf('%dx%d %s',rows,columns,valueType);
    end
end

function cleanupFunction(modelName,wasLoaded,currHarness,deactivateHarness,oldHarness,wasHarnessOpen)
    stm.internal.slrealtime.FollowProgress.progress('** Cleanup  **');

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
