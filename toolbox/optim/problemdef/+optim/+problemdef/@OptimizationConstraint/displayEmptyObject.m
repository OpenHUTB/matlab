function displayEmptyObject(obj)





    sizeStr=matlab.mixin.CustomDisplay.convertDimensionsToString(obj);
    classTitle=matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
    typeText=getString(message('shared_adlib:OptimizationExpression:Array'));
    emptyStr=getString(message('shared_adlib:OptimizationExpression:Empty'));

    fprintf('  %s %s %s %s\n',sizeStr,emptyStr,classTitle,typeText);



    if~strcmp(get(0,'FormatSpacing'),'compact')
        fprintf('\n');
    end