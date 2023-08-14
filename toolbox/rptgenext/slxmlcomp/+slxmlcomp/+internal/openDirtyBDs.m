

function openDirtyBDs(modelPath)

    [~,modelName,~]=fileparts(modelPath);
    if(~bdIsLoaded(modelName)...
        ||~strcmp(get_param(modelName,'FileName'),modelPath))
        return
    end

    testHarnesses=getAttachedTestHarnessNames(modelName);

    testHarnessDirty=false;
    for thIndex=1:numel(testHarnesses)
        if(bdIsLoaded(testHarnesses{thIndex})...
            &&strcmp(get_param(testHarnesses{thIndex},'Dirty'),'on'))
            testHarnessDirty=true;
        end
    end

    if((testHarnessDirty||strcmp(get_param(modelName,'Dirty'),'on'))...
        &&strcmp(get_param(modelName,'open'),'off'))


        for thIndex=1:numel(testHarnesses)
            close_system(testHarnesses{thIndex},0);
        end

        set_param(modelName,'open','on');
    end

end

function testHarnessNames=getAttachedTestHarnessNames(modelName)

    harnesses=Simulink.harness.internal.find(modelName);

    testHarnessNames=cell(size(harnesses));
    for ii=1:numel(harnesses)
        testHarnessNames{ii}=harnesses(ii).name;
    end

end