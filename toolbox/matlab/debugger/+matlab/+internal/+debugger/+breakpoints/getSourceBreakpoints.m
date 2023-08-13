function breakpointInfos=getSourceBreakpoints()
    dbstatusReturn=dbstatus('-completenames');
    breakpointInfos=matlab.internal.debugger.breakpoints.convertDBStatusToBreakpointInfo(dbstatusReturn);
end
