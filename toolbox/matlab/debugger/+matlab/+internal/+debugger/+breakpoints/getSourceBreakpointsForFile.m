function breakpointInfos=getSourceBreakpointsForFile(filename)

    try
        dbstatusReturn=dbstatus('-completenames',filename);
        filteredDbstatusReturn=filterExactFilenameMatchesOnly(dbstatusReturn,filename);
        breakpointInfos=matlab.internal.debugger.breakpoints.convertDBStatusToBreakpointInfo(filteredDbstatusReturn);
    catch ME

        breakpointInfos=[];
    end
end

function filteredDbstatusReturn=filterExactFilenameMatchesOnly(dbstatusReturn,filename)




    filteredDbstatusReturn=dbstatusReturn(strcmp({dbstatusReturn.file},filename));
end