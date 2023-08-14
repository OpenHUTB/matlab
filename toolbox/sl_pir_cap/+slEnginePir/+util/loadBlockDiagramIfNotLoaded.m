function success=loadBlockDiagramIfNotLoaded(modelFullPath)




    success=false;
    [folderPath,modelNameWithoutExtension,~]=fileparts(modelFullPath);

    if~exist(modelFullPath,'file')
        addpath(folderPath);
        removedFolder=onCleanup(@()rmpath(folderPath));
    end
    if~bdIsLoaded(modelNameWithoutExtension)
        load_system(modelFullPath);
        success=true;
    end
end

