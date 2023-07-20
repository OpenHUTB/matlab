function buildModel(modelToRun)


    targetType=get_param(modelToRun,'SystemTargetFile');
    if~(strcmpi(targetType,'slrealtime.tlc'))
        error(message('stm:realtime:UnsupportedTarget',targetType));
    end


    currModelStatus=get_param(modelToRun,'SimulationStatus');
    if(~strcmpi(currModelStatus,'stopped'))
        error(message('stm:general:CannotRunModelNotStopped',modelToRun));
    end

    isModelDirty=strcmpi(get_param(modelToRun,'Dirty'),'on');




    usedConfigSet=getActiveConfigSet(modelToRun);
    if~isa(usedConfigSet,'Simulink.ConfigSetRef')

        isRTWVerboseOn=strcmpi(get_param(modelToRun,'RTWVerbose'),'on');
        revertConfig=onCleanup(@()revertModelConfig(modelToRun,isRTWVerboseOn,false,isModelDirty));

        if isRTWVerboseOn
            set_param(modelToRun,'RTWVerbose','off');
        end

    else
        revertConfig=onCleanup(@()revertModelConfig(modelToRun,false,false,isModelDirty));
    end


    evalc('slbuild(modelToRun)');


    if~exist([modelToRun,'.mldatx'],'file')
        error(message('stm:realtime:NoMldatxFileWasCreated'));
    end
end

function revertModelConfig(mdl,isRTWVerboseOn,~,isModelDirty)

    if isRTWVerboseOn
        set_param(mdl,'RTWVerbose','on');
    end


    if~isModelDirty
        set_param(mdl,'Dirty','off');
    end
end
