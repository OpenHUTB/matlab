function visitOperatorStaticSubsref(visitor,Op,~)






    addParens=Inf;


    [leftVarName,leftParens]=getChildArgumentName(visitor,1,addParens);
    leftDependsOnLoopVar=childDependsOnLoopVar(visitor,1);




    addParens=1;
    [indexingStr,indexingParens,indexDependsOnLoopVar]=visitStaticIndexingString(visitor,Op,addParens);


    funStr=leftVarName+"("+indexingStr+")";
    numParens=leftParens+indexingParens;
    isArgOrVar=false;
    isAllZero=false;
    singleLine=true;


    push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);
    dependsOnLoopVar=indexDependsOnLoopVar||leftDependsOnLoopVar;
    pushDependsOnLoopVar(visitor,dependsOnLoopVar);

end
