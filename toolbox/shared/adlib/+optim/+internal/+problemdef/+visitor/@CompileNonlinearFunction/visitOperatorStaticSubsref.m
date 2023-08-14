function visitOperatorStaticSubsref(visitor,Op,~)






    addParens=Inf;


    [leftVarName,leftParens]=getChildArgumentName(visitor,1,addParens);




    addParens=1;
    [indexingStr,indexingParens]=visitStaticIndexingString(visitor,Op,addParens);


    funStr=leftVarName+"("+indexingStr+")";
    numParens=leftParens+indexingParens;
    isArgOrVar=false;
    isAllZero=false;
    singleLine=true;


    push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);

end
