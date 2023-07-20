

function cloneDetectionSettings=guiDataToAPISettingsAdapter(cloneDetectionUI,cloneDetectionSettings)





    cloneDetectionSettings.IgnoreSignalName=cloneDetectionUI.ignoreSignalName;
    cloneDetectionSettings.IgnoreBlockProperty=...
    cloneDetectionUI.ignoreBlockProperty;
    cloneDetectionSettings.ReplaceExactClonesWithSubsystemReference=...
    cloneDetectionUI.isReplaceExactCloneWithSubsysRef;
    cloneDetectionSettings.ParamDifferenceThreshold=...
    str2num(['uint32(',cloneDetectionUI.parameterThreshold,')']);
    cloneDetectionSettings.ExcludeModelReferences=...
    cloneDetectionUI.excludeModelReferences;
    cloneDetectionSettings.ExcludeLibraryLinks=...
    cloneDetectionUI.excludeLibraries;
    cloneDetectionSettings.ExcludeInactiveRegions=...
    cloneDetectionUI.excludeInactiveRegions;
    cloneDetectionSettings.Libraries=cloneDetectionUI.libraryList;

    cloneDetectionSettings.DetectClonesAcrossModel=...
    cloneDetectionUI.enableClonesAnywhere;
    if(cloneDetectionUI.enableClonesAnywhere)
        cloneDetectionSettings.MinimumRegionSize=...
        cloneDetectionUI.regionSize;
        cloneDetectionSettings.MinimumCloneGroupSize=...
        cloneDetectionUI.cloneGroupSize;
    end

end
