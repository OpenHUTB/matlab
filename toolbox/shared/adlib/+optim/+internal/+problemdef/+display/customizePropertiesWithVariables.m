function groupStr=customizePropertiesWithVariables(obj,groupStr)










    if isFormatCompact
        groupStr=groupStr(1:end-1);
    else
        groupStr=groupStr(1:end-2);
    end



    groupStr=string(groupStr);

    groupStr=optim.internal.problemdef.display.dispObjCounts(groupStr,"Variables",obj.Variables,"OptimizationVariable");

    function ifc=isFormatCompact

        formatSpacing=get(0,'FormatSpacing');
        ifc=isequal(formatSpacing,'compact');

