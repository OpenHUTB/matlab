function closeAll(modelName,namesToIgnore)



    if nargin<2
        namesToIgnore={};
    end




    loadedModelsBeforeFind=find_system('type','block_diagram');
    harnesses=Simulink.harness.find(modelName);
    loadedModelsAfterFind=find_system('type','block_diagram');

    for ii=1:numel(harnesses)
        harness=harnesses(ii);
        if harness.isOpen&&~ismember(harness.name,namesToIgnore)
            bdclose(harness.name);
        end
    end

    modelsLoadedByFind=setdiff(loadedModelsAfterFind,loadedModelsBeforeFind);
    close_system(modelsLoadedByFind,0);

end

