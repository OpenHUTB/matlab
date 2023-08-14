function displayNonScalarObject(obj)







    className=matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
    dimstr=matlab.mixin.CustomDisplay.convertDimensionsToString(obj);
    optim.internal.problemdef.display.printXEqualsLine(obj,className,dimstr);



    groupStr=evalc('matlab.mixin.CustomDisplay.displayPropertyGroups(obj, getPropertyGroups(obj))');


    groupStr=optim.internal.problemdef.display.customizePropertiesWithVariables(obj,groupStr);


    fprintf('%s\n\n',groupStr);



    fprintf('%s',getFooter(obj));
    optim.internal.problemdef.display.blankLine;

