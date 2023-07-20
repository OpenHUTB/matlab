








function upToDate=checkRebuildInfoForMATLABSystemDeps(cachedInfo)

    if isempty(cachedInfo)
        upToDate=true;
        return;
    end

    changed=matlab.system.MLSysBlockRebuildConditionInfo.getMLSysBlockRebuildCondition(cachedInfo);

    if changed
        upToDate=false;
        return;
    end

    upToDate=true;
