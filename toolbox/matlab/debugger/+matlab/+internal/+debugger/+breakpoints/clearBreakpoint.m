function clearBreakpoint(breakpointInfo)
    lineNumberString=int2str(breakpointInfo.lineNumber);

    if(breakpointInfo.anonymousIndex>0)
        anonymousFunctionIndexString=int2str(breakpointInfo.anonymousIndex);
        lineNumberString=[lineNumberString,'@',anonymousFunctionIndexString];
    end

    try
        dbclear('-completenames',breakpointInfo.fileName,lineNumberString);
    catch err


    end
end