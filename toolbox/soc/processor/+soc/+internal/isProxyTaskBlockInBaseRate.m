function ret=isProxyTaskBlockInBaseRate(modelName)




    info=soc.internal.getProxyTaskInfo(modelName);
    ret=info.hasTimerDrivenInBaseRate;
end
