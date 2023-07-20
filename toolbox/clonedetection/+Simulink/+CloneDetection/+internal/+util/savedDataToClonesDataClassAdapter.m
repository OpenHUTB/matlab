
function clonesRawData=savedDataToClonesDataClassAdapter(clonesRawData,...
    clonesSavedData)



    if isa(clonesRawData,'Simulink.CloneDetection.internal.ClonesData')
        if isa(clonesSavedData,'CloneDetectionUI.CloneDetectionUI')
            clonesRawData.model=clonesSavedData.model;
            clonesRawData.systemFullName=clonesSavedData.systemFullName;
            clonesRawData.m2mObj=clonesSavedData.m2mObj;
            clonesRawData.isAcrossModel=clonesSavedData.isAcrossModel;
            clonesRawData.listOfFolders=clonesSavedData.listOfFolders;
            clonesRawData.libraryList=clonesSavedData.libraryList;
            clonesRawData.excludeLibraries=clonesSavedData.excludeLibraries;
            clonesRawData.excludeModelReferences=clonesSavedData.excludeModelReferences;
            clonesRawData.excludeInactiveRegions=clonesSavedData.excludeInactiveRegions;
            clonesRawData.excludeCloneDetection=clonesSavedData.excludeCloneDetection;
            clonesRawData.parameterThreshold=clonesSavedData.parameterThreshold;
            clonesRawData.parameterThreshold_old=clonesSavedData.parameterThreshold_old;
            clonesRawData.defaultThreshold=clonesSavedData.defaultThreshold;
            clonesRawData.refactorOptions=clonesSavedData.refactorOptions;
            clonesRawData.cloneGroupSidListMap=clonesSavedData.cloneGroupSidListMap;
            clonesRawData.backUpPath=clonesSavedData.backUpPath;
            clonesRawData.historyVersions=clonesSavedData.historyVersions;
            clonesRawData.backupModel=clonesSavedData.backupModel;
            clonesRawData.objectFile=clonesSavedData.objectFile;
            clonesRawData.blockPathCategoryMap=clonesSavedData.blockPathCategoryMap;

            clonesRawData.refactoredClonesLibFileName=clonesSavedData.refactoredClonesLibFileName;
            clonesRawData.cloneDetectionStatus=clonesSavedData.cloneDetectionStatus;
            clonesRawData.metrics=clonesSavedData.metrics;
            clonesRawData.totalBlocks=clonesSavedData.totalBlocks;
            clonesRawData.ignoreSignalName=clonesSavedData.ignoreSignalName;
            clonesRawData.ignoreBlockProperty=clonesSavedData.ignoreBlockProperty;
            clonesRawData.isReplaceExactCloneWithSubsysRef=clonesSavedData.isReplaceExactCloneWithSubsysRef;
            clonesRawData.enableClonesAnywhere=clonesSavedData.enableClonesAnywhere;
        elseif isa(clonesSavedData,'Simulink.CloneDetection.internal.ClonesData')
            clonesRawData=clonesSavedData;
        end
    end
end

