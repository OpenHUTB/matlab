function clonesRawData=updateReplaceClonesConfig(clonesRawData,...
    cloneReplacementConfig)




    clonesRawData.refactoredClonesLibFileName=...
    cloneReplacementConfig.LibraryNameToAddSubsystemsTo;
    if length(cloneReplacementConfig.IgnoredClones)>=1
        for cloneIndex=1:length(cloneReplacementConfig.IgnoredClones)
            cloneName=cloneReplacementConfig.IgnoredClones{cloneIndex};
            Simulink.CloneDetection.internal.util.m2m_toggle_sysclone...
            (clonesRawData.m2mObj,cloneName,0);


            Simulink.CloneDetection.internal.util.saveCloneDetectionUIObj(clonesRawData);
        end
    end
end
