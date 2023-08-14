function undoRefactorCallback(modelHandle,historyIndex)




    cloneDetectionUIObj=get_param(modelHandle,'CloneDetectionUIObj');
    version=cloneDetectionUIObj.historyVersions{historyIndex};

    try
        loadedObject=load([cloneDetectionUIObj.backUpPath,version,'.mat']);
        activeCloneDetectionUIObj=loadedObject.updatedObj;
    catch
        DAStudio.error('sl_pir_cpp:creator:historyVesionNotFound',version,...
        ['m2m_',get_param(modelHandle,'name')]);
    end

    models=[{activeCloneDetectionUIObj.m2mObj.mdl},...
    activeCloneDetectionUIObj.m2mObj.refModels];
    backupModelPrefix=activeCloneDetectionUIObj.m2mObj.genmodelprefix;
    changelibraries=activeCloneDetectionUIObj.m2mObj.changedLibraries.keys;

    slEnginePir.undoModelRefactor(models,backupModelPrefix,cloneDetectionUIObj.backUpPath);
    if~isempty(changelibraries)
        slEnginePir.undoModelRefactor(changelibraries,backupModelPrefix,...
        cloneDetectionUIObj.backUpPath);
    end

end


