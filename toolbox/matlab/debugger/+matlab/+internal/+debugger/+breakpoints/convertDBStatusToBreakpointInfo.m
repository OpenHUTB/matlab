function allBreakpointInfos=convertDBStatusToBreakpointInfo(dbstatusResult)

    allBreakpointInfos=struct([]);
    for i=1:length(dbstatusResult)
        dbStatusEntry=dbstatusResult(i);
        breakpointInfos=extractFilesBreakpoints(dbStatusEntry);
        allBreakpointInfos=cat(1,allBreakpointInfos,breakpointInfos);
    end
end


function breakpointInfos=extractFilesBreakpoints(dbStatusEntry)

    numBreakpoints=length(dbStatusEntry.line);
    breakpointInfos=struct([]);

    file=dbStatusEntry.file;

    for i=1:numBreakpoints
        oneBasedLineNumber=dbStatusEntry.line(i);
        if oneBasedLineNumber==0


            continue;
        end

        anonymousFunctionIndex=dbStatusEntry.anonymous(i);
        expression=dbStatusEntry.expression{i};

        breakpoint=matlab.internal.debugger.breakpoints.createSourceBreakpoint(...
        file,oneBasedLineNumber,expression,anonymousFunctionIndex);

        breakpointInfos=cat(1,breakpointInfos,breakpoint);
    end
end