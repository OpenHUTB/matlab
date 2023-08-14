function tmpPath=saveModelToLatestVersion(modelPath)





    tmpPath=[tempname,'.slx'];


    state=warning('off');
    cleanup=onCleanup(@()warning(state));


    initOpenModels=find_system('type','block_diagram');


    [~,modelName]=fileparts(modelPath);
    if~(bdIsLoaded(modelName)&&strcmp(get_param(modelName,'Filename'),modelPath))
        [~,modelName]=fileparts(tempname);
        Simulink.internal.newSystemFromFile(modelName,modelPath,ExecuteCallbacks=false);
    end


    slInternal('snapshot_slx',modelName,tmpPath);


    currentOpenModels=find_system('type','block_diagram');
    newlyOpenModels=setdiff(currentOpenModels,initOpenModels);
    close_system(newlyOpenModels,0,'SkipCloseFcn',true);

end
