function displayScalarObject(con)





    className=matlab.mixin.CustomDisplay.getClassNameForHeader(con);
    optim.internal.problemdef.display.printXEqualsLine(con,className);


    prettyPrintConstraint(con);

    function prettyPrintConstraint(con)


        if~isLinear(con)

            showExtraParamsLink=matlab.internal.display.isHot&&~isdeployed;
            [conStr,extraParamsStr]=expandNonlinearStr(con,showExtraParamsLink);
            conStr=optim.internal.problemdef.display.printNonlinearForCommandWindow(...
            conStr,extraParamsStr,true,con.objectType());
            initialSpace="  ";
        else

            [conStr,~,hasHTML]=expand2str(con);


            truncate=~hasHTML;

            conStr=optim.internal.problemdef.display.printForCommandWindow(conStr,truncate,con.objectType());
            initialSpace="    ";
        end


        fprintf('%s%s\n',initialSpace,conStr);
        optim.internal.problemdef.display.blankLine;
