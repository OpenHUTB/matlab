function warnForForcedExpansion(sigIDs)

    Simulink.sdi.internal.warning(message('SDI:sdi:LAForcedExpansionWarning'));


    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    repo=sdi.Repository(1);
    runIDs=zeros(size(sigIDs),'int32');
    for idx=1:numel(sigIDs)
        runIDs(idx)=repo.getSignalRunID(sigIDs(idx));
    end
    runIDs=unique(runIDs);

    for idx=1:numel(runIDs)
        fw.onSignalAdded(runIDs(idx));
    end
end