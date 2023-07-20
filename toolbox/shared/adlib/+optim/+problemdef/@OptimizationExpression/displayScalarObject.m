function displayScalarObject(expr)











    className=matlab.mixin.CustomDisplay.getClassNameForHeader(expr);
    optim.internal.problemdef.display.printXEqualsLine(expr,className);


    prettyPrintExpression(expr);

    function prettyPrintExpression(expr)


        if isNonlinear(expr)
            showExtraParamsLink=matlab.internal.display.isHot&&~isdeployed;
            [exprStr,extraParamsStr]=expandNonlinearStr(expr,showExtraParamsLink);
            exprStr=optim.internal.problemdef.display.printNonlinearForCommandWindow(...
            exprStr,extraParamsStr,true,'expression');
            initialSpace="  ";
        else

            [exprStr,~,hasHTML]=expand2str(expr);


            truncate=~hasHTML;

            exprStr=optim.internal.problemdef.display.printForCommandWindow(exprStr,truncate,'expression');
            initialSpace="    ";
        end


        fprintf('%s%s\n',initialSpace,exprStr);
        optim.internal.problemdef.display.blankLine;

