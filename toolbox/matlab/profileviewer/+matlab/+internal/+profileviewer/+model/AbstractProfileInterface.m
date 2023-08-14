classdef(Abstract)AbstractProfileInterface<handle





    events

ProfileInterfaceEvent
    end

    methods
        function obj=AbstractProfileInterface
            mlock;
        end
    end

    methods(Abstract)
        timer=getProfileTimer(~)
        profilerInvokedStatus=getProfilerInvokedStatus(~)
        historyTracking=getHistoryTracking(~)
        historySize=getHistorySize(~)
        functionHistory=getFunctionHistory(~)
        profileInfo=getProfileInfo(obj)
        fileLines=getFileLines(~,fileName)
        fileChanged=hasFileChangedDuringProfiling(~,functionCompleteName)
        turnOff(~)
        clear(~)
        viewer(~)
        status=getProfilerStatus(~)
    end
end
