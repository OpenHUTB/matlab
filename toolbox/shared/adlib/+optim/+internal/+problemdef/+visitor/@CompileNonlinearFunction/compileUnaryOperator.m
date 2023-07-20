function compileUnaryOperator(visitor,op,~)





    addParens=getOutputParens(op);


    [leftVarName,leftParens]=getChildArgumentName(visitor,1,addParens);


    [funStr,numParens]=buildNonlinearStr(op,visitor,...
    leftVarName,[],leftParens,[]);
    isArgOrVar=false;
    isAllZero=false;
    singleLine=true;


    push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);

end
