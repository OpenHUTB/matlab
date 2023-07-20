function writeCompiledMetaData(configObj,datamgr)







    suffix=configObj.getTargetLangSuffix();
    mainFile=fullfile(configObj.getDerivedCodeFolder(),...
    [configObj.getModelName(),suffix]);
    mainFile=slci.results.normalizeFilePath(mainFile);
    metaData.inspectedCodeFiles.filesToTrace{1}=mainFile;


    metaData.modelCheckSum=...
    slci.internal.getModelChecksum(...
    configObj.getModelName(),configObj.getTopModel());


    datamgr.beginTransaction();
    try
        datamgr.setMetaData('InspectedCodeFiles',metaData.inspectedCodeFiles);
        datamgr.setMetaData('ModelChecksum',metaData.modelCheckSum);
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end
    datamgr.commitTransaction();

end
