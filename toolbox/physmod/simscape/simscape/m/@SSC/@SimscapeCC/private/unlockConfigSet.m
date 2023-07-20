function lockData=unlockConfigSet(configSet)








    MAX_ATTEMPTS=1000;
    lockData.numLevels=0;

    while configSet.isObjectLocked&&(lockData.numLevels<=MAX_ATTEMPTS)
        configSet.unlock;
        lockData.numLevels=lockData.numLevels+1;
    end

    if lockData.numLevels>MAX_ATTEMPTS
        pm_error('physmod:simscape:simscape:SSC:SimscapeCC:private:unlockConfigSet:MaxCountExceeded',...
        MAX_ATTEMPTS);
    end




