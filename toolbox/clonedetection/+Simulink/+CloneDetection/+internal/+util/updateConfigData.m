function clonesRawData=updateConfigData(clonesRawData,cloneDetectionSettings)




    clonesRawData.ignoreSignalName=cloneDetectionSettings.IgnoreSignalName;
    clonesRawData.ignoreBlockProperty=cloneDetectionSettings.IgnoreBlockProperty;
    clonesRawData.isReplaceExactCloneWithSubsysRef=...
    cloneDetectionSettings.ReplaceExactClonesWithSubsystemReference;
    clonesRawData.enableClonesAnywhere=cloneDetectionSettings.DetectClonesAcrossModel;
    if(clonesRawData.enableClonesAnywhere)
        clonesRawData.regionSize=cloneDetectionSettings.MinimumRegionSize;
        clonesRawData.cloneGroupSize=cloneDetectionSettings.MinimumCloneGroupSize;
    end
    clonesRawData.parameterThreshold=...
    int2str(cloneDetectionSettings.ParamDifferenceThreshold);

    clonesRawData.excludeModelReferences=...
    cloneDetectionSettings.ExcludeModelReferences;
    clonesRawData.excludeLibraries=cloneDetectionSettings.ExcludeLibraryLinks;
    clonesRawData.excludeInactiveRegions=...
    cloneDetectionSettings.ExcludeInactiveRegions;

    clonesRawData.libraryList=cloneDetectionSettings.Libraries;

    if~isempty(cloneDetectionSettings.Folders)
        clonesRawData.listOfFolders=cloneDetectionSettings.Folders;
        clonesRawData.isAcrossModel=1;
        clonesRawData.FindClonesRecursivelyInFolders=...
        cloneDetectionSettings.FindClonesRecursivelyInFolders;
    end
end
