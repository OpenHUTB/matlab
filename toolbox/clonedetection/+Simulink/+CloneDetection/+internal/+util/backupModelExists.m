


function modelsExists=backupModelExists(clonesData)
    modelsExists=false;

    originalModelName=get_param(clonesData.model,'name');
    if~isempty(clonesData.libraryList)
        backupModelName=slEnginePir.util.getBackupModelName(clonesData.m2mObj.genmodelprefix,...
        originalModelName);
    else
        backupModelName=slEnginePir.util.getTemporaryModelName(clonesData.m2mObj.genmodelprefix,...
        originalModelName);
    end

    try
        [~,~]=Simulink.CloneDetection.internal.util.checkFileInAllPaths(...
        [clonesData.m2mObj.m2m_dir,backupModelName]);
        modelsExists=true;
    catch
        DAStudio.error('sl_pir_cpp:creator:BackupModelNotFound',backupModelName);
    end
end

