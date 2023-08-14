function isCurrentML=getMRTEnvironment()


    persistent currentRelease
    if isempty(currentRelease)
        currentRelease=stm.internal.util.getReleaseInfo();
    end
    poolInfo=stm.internal.MRT.mrtpool.getWorkerInfo();
    if(isempty(poolInfo.hostRelease))
        isCurrentML=true;
    else
        isCurrentML=strcmp(currentRelease,poolInfo.hostRelease);
    end
end