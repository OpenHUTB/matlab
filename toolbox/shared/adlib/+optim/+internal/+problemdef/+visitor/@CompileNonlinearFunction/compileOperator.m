function compileOperator(visitor,op,~)





    addParens=getOutputParens(op);


    [leftVarName,leftParens]=getChildArgumentName(visitor,1,addParens);
    [rightVarName,rightParens]=getChildArgumentName(visitor,2,leftParens+addParens);


    [funStr,numParens]=buildNonlinearStr(op,visitor,...
    leftVarName,rightVarName,leftParens,rightParens);
    isArgOrVar=false;
    isAllZero=false;
    singleLine=true;


    push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);

end
