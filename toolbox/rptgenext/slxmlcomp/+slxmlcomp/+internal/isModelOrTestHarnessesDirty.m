

function dirty=isModelOrTestHarnessesDirty(modelPath)

    mdlDirty=isModelDirty(modelPath);
    thDirty=attachedTestHarnessesAreDirty(modelPath);
    dirty=mdlDirty||thDirty;
end

function isDirty=isModelDirty(modelPath)
    [~,modelName,~]=fileparts(modelPath);

    isDirty=isModelPathLoaded(modelPath)...
    &&strcmp(get_param(modelName,'Dirty'),'on');
end

function areDirty=attachedTestHarnessesAreDirty(modelPath)

    areDirty=false;
    if(~isModelPathLoaded(modelPath))
        return;
    end

    [~,modelName,~]=fileparts(modelPath);

    harnesses=Simulink.harness.internal.find(modelName);
    for ii=1:numel(harnesses)
        harness=harnesses(ii).name;
        if(bdIsLoaded(harness)...
            &&strcmp(get_param(harness,'FileName'),modelPath)...
            &&strcmp(get_param(harness,'dirty'),'on'))
            areDirty=true;
            return;
        end
    end

end

function isLoaded=isModelPathLoaded(modelPath)
    [~,modelName,~]=fileparts(modelPath);

    isLoaded=bdIsLoaded(modelName)...
    &&strcmp(get_param(modelName,'FileName'),modelPath);
end