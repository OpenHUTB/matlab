function errorResult=clearAndSetBreakpointsForFile(filename,requestedBreakpoints)
    errorResult=[];

    clear(filename);


    quietlyClearBreakpoints(filename);

    if nargin==1
        return;
    end

    requestedBreakpoints=mls.internal.fromJSON(requestedBreakpoints);


    drawnow;

    try
        quietlySetBreakpoints(requestedBreakpoints);
    catch err
        errorResult=struct('id',{err.identifier},'message',{err.message});
    end
end



function possibleError=quietlySetBreakpoints(requestedBreakpoints)
    for i=1:length(requestedBreakpoints)


        matlab.internal.debugger.breakpoints.setBreakpoint(requestedBreakpoints(i))
    end
end

function quietlyClearBreakpoints(filename)

    try
        dbclear("-completenames",filename);
    catch exception %#ok<NASGU>

    end
end
