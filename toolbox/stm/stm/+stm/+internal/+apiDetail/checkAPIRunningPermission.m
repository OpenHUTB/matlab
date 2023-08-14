function checkAPIRunningPermission(apiName)






    if(stm.internal.getTestRunningFlag())
        error(message('stm:general:OperationProhibitedWhileTestRunning',apiName));
    end
    if(stm.internal.getScriptRunningFlag())
        error(message('stm:general:OperationProhibitedInScript',apiName));
    end
    if stm.internal.isAdapterRunning
        error(message('stm:LinkToExternalFile:OperationNotSupported',apiName));
    end
end