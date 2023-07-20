function CloseExternalDebuggerWithProcess(exePIDStr)
    isOOP=true;
    if nargin<1
        isOOP=false;
    end

    if isOOP
        SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().clearSLCCOOPSILDebugger(char(exePIDStr));
    else
        SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().clearSLCCInProcessDebugger();
    end
end
