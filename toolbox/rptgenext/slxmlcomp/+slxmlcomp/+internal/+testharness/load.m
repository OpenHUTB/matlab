function inMemoryHarnessName=load(modelPath,harnessName,rename)





    slxmlcomp.internal.loadModel(modelPath);
    [~,modelName]=fileparts(modelPath);

    harnessChangeWarning='Simulink:Harness:BlockDiagramHarnessNameChange';
    warning('off',harnessChangeWarning);
    restoreHarnessWarning=onCleanup(@()warning('on',harnessChangeWarning));
    modelNotFoundWarning='Simulink:modelReference:ModelNotFoundWithBlockName';
    warning('off',modelNotFoundWarning);
    restoreNotFoundWarning=onCleanup(@()warning('on',modelNotFoundWarning));

    inMemoryHarnessName=slxmlcomp.internal.testharness.getHarnessMemName(...
    modelPath,...
    harnessName,...
rename...
    );

    import slxmlcomp.internal.testharness.MemoryNames;
    if rename
        if bdIsLoaded(inMemoryHarnessName)
            return
        end
        Simulink.harness.internal.load_harness_from_file(...
        modelName,harnessName,inMemoryHarnessName...
        );
    else
        closeClashingTestHarnesses(modelName,harnessName);
        owner=Simulink.harness.find(modelName,'Name',harnessName);
        Simulink.harness.load(owner.ownerFullPath,harnessName);
        inMemoryHarnessName=harnessName;
    end

end


function closeClashingTestHarnesses(modelName,harnessName)

    systems=find_system('type','block_diagram');
    isModelSystem=strcmp(systems,modelName);
    slxmlcomp.internal.testharness.closeAll(systems{isModelSystem},{harnessName});

    isLoaded=bdIsLoaded(systems);
    loadedNotModelSystems=systems(isLoaded&~isModelSystem);

    modelHarnesses=cellfun(@Simulink.harness.find,loadedNotModelSystems,'UniformOutput',false);
    modelHarnesses=horzcat(modelHarnesses{:});
    if~isempty(modelHarnesses)
        haveSameName=strcmp({modelHarnesses(:).name},harnessName);
        areOpen=[modelHarnesses.isOpen];
        if any(haveSameName&areOpen)
            close_system(modelHarnesses(haveSameName&areOpen).name,0);
        end
    end

end
