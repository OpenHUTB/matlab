function compileWithSubasgnNoSubsref(visitor,treeHeadIdx,forestIdxStr)











    treeJacIsAllZero=isChildJacAllZero(visitor,treeHeadIdx);

    if~treeJacIsAllZero



        addParens=0;
        treeJacStr=getChildJacArgumentName(visitor,treeHeadIdx,addParens);




        forestJacStr=visitor.ForestJacName;
        forestJacIdxStr="(:,"+forestIdxStr+")";
        visitor.ExprAndJacBody=visitor.ExprAndJacBody+forestJacStr+forestJacIdxStr+" = "+treeJacStr+";"+newline;


        visitor.ForestJacIsAllZero=treeJacIsAllZero;
    end


    compileWithSubasgnNoSubsref@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,...
    treeHeadIdx,forestIdxStr);
