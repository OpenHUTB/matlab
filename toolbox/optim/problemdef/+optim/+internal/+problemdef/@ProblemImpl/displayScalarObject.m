function displayScalarObject(prob)







    isFormatCompact=strcmp(get(0,'FormatSpacing'),'compact');


    header=getHeader(prob);
    disp(header);



    groupStr=evalc('matlab.mixin.CustomDisplay.displayPropertyGroups(prob, getCustomPropertyGroup(prob))');


    groupStr=optim.internal.problemdef.display.customizePropertiesWithVariables(prob,groupStr);


    groupStr=customizeObjectivesProperty(prob,groupStr);


    groupStr=customizeConstraintsProperty(prob,groupStr);


    fprintf('%s\n\n',groupStr);


    if~(isempty(prob.ObjectivesStore)&&isempty(prob.ConstraintsStore))
        footer=getFooter(prob);
    else
        footer=sprintf('  %s',getString(...
        message('optim_problemdef:ProblemImpl:NoProblemDefinedFooter')));
        if~isFormatCompact
            footer=sprintf('%s\n',footer);
        end
    end
    disp(footer);

end