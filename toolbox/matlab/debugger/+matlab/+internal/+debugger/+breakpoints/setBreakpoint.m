function setBreakpoint(breakpointInfo)

    if~breakpointInfo.isEnabled

        expression='false';
        if~isempty(breakpointInfo.expression)
            expression=['false&&(',char(breakpointInfo.expression),')'];
        end
        breakpointInfo.expression=expression;
    end

    lineNumberString=int2str(breakpointInfo.lineNumber);

    if(breakpointInfo.anonymousIndex>0)
        anonymousFunctionIndexString=int2str(breakpointInfo.anonymousIndex);
        lineNumberString=[lineNumberString,'@',anonymousFunctionIndexString];
    end

    if(~isempty(breakpointInfo.expression))
        expressionString=char(breakpointInfo.expression);
        dbstop('-completenames',breakpointInfo.fileName,lineNumberString,'if',expressionString);
    else
        dbstop('-completenames',breakpointInfo.fileName,lineNumberString);
    end
end