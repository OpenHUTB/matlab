function clonesDataObject=guiToAPIClonesDataAdapter(clonesDataObject,cloneDetectionUIObject)




    if isa(cloneDetectionUIObject,'CloneDetectionUI.CloneDetectionUI')
        clonesDataObject.model=cloneDetectionUIObject.model;
        clonesDataObject.systemFullName=cloneDetectionUIObject.systemFullName;
        clonesDataObject.m2mObj=cloneDetectionUIObject.m2mObj;
        clonesDataObject.isAcrossModel=cloneDetectionUIObject.isAcrossModel;
        clonesDataObject.listOfFolders=cloneDetectionUIObject.listOfFolders;
        clonesDataObject.libraryList=cloneDetectionUIObject.libraryList;
        clonesDataObject.excludeLibraries=cloneDetectionUIObject.excludeLibraries;
        clonesDataObject.excludeModelReferences=cloneDetectionUIObject.excludeModelReferences;
        clonesDataObject.excludeInactiveRegions=cloneDetectionUIObject.excludeInactiveRegions;
        clonesDataObject.excludeCloneDetection=cloneDetectionUIObject.excludeCloneDetection;
        clonesDataObject.parameterThreshold=cloneDetectionUIObject.parameterThreshold;
        clonesDataObject.parameterThreshold_old=cloneDetectionUIObject.parameterThreshold_old;
        clonesDataObject.defaultThreshold=cloneDetectionUIObject.defaultThreshold;
        clonesDataObject.refactorOptions=cloneDetectionUIObject.refactorOptions;
        clonesDataObject.cloneGroupSidListMap=cloneDetectionUIObject.cloneGroupSidListMap;
        clonesDataObject.backUpPath=cloneDetectionUIObject.backUpPath;
        clonesDataObject.historyVersions=cloneDetectionUIObject.historyVersions;
        clonesDataObject.backupModel=cloneDetectionUIObject.backupModel;
        clonesDataObject.objectFile=cloneDetectionUIObject.objectFile;
        clonesDataObject.blockPathCategoryMap=cloneDetectionUIObject.blockPathCategoryMap;

        clonesDataObject.refactoredClonesLibFileName=cloneDetectionUIObject.refactoredClonesLibFileName;
        clonesDataObject.cloneDetectionStatus=cloneDetectionUIObject.cloneDetectionStatus;
        clonesDataObject.metrics=cloneDetectionUIObject.metrics;
        clonesDataObject.totalBlocks=cloneDetectionUIObject.totalBlocks;
        clonesDataObject.ignoreSignalName=cloneDetectionUIObject.ignoreSignalName;
        clonesDataObject.ignoreBlockProperty=cloneDetectionUIObject.ignoreBlockProperty;
        clonesDataObject.isReplaceExactCloneWithSubsysRef=cloneDetectionUIObject.isReplaceExactCloneWithSubsysRef;
        clonesDataObject.CloneResults=cloneDetectionUIObject.CloneResults;
        clonesDataObject.ReplaceResults=cloneDetectionUIObject.ReplaceResults;
        clonesDataObject.EquivalencyCheckResults=cloneDetectionUIObject.EquivalencyCheckResults;
    end
end



