function reportProfilingError(errorID,taskID,coreID,timerValue)
    messageID=['soc:taskprofiler:TaskProfilerErrorID',num2str(errorID)];
    if errorID>1
        MSLDiagnostic(messageID,taskID,coreID,num2str(timerValue)).reportAsWarning;
    else
        MSLDiagnostic(messageID).reportAsWarning;
    end
end
