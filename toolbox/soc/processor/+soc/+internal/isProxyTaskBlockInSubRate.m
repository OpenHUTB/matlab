function ret=isProxyTaskBlockInSubRate(modelName)




    info=soc.internal.getProxyTaskInfo(modelName);
    ret=info.hasTimerDrivenInSubRate;
end