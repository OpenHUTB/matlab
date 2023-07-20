function blankLine








    if isFormatCompact

    else
        fprintf('\n');
    end

    function ifc=isFormatCompact

        formatSpacing=get(0,'FormatSpacing');
        ifc=isequal(formatSpacing,'compact');
