function compileWithSubsasgnWithSubsref(visitor,treeHeadIdx,forestIdxStr,treeIdxStr)








    treeJacIsAllZero=isChildJacAllZero(visitor,treeHeadIdx);

    if~treeJacIsAllZero





        addParens=Inf;
        treeJacStr=getChildJacArgumentName(visitor,treeHeadIdx,addParens);


        forestJacStr=visitor.ForestJacName;


        treeJacIdxStr="(:,"+treeIdxStr+")";


        forestJacIdxStr="(:,"+forestIdxStr+")";


        treeJacBody=...
        forestJacStr+forestJacIdxStr+" = "+treeJacStr+treeJacIdxStr+";"+newline;


        visitor.ExprAndJacBody=visitor.ExprAndJacBody+treeJacBody;


        visitor.ForestJacIsAllZero=treeJacIsAllZero;
    end


    compileWithSubsasgnWithSubsref@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,...
    treeHeadIdx,forestIdxStr,treeIdxStr);

end
