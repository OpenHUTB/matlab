function displayScalarObject(obj)







    isFormatCompact=strcmp(get(0,'FormatSpacing'),'compact');



    fprintf('%s\n',getHeader(obj));



    displayProperties(obj);
    if isFormatCompact
        fprintf('\n');
    end



    fprintf('%s',getFooter(obj));
    if~isFormatCompact
        fprintf('\n');
    end

    function displayProperties(obj)

        groups=getPropertyGroups(obj);
        matlab.mixin.CustomDisplay.displayPropertyGroups(obj,groups);