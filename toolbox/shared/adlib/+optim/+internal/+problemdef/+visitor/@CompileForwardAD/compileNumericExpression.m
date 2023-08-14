function[funStr,numParens,isArgOrVar]=compileNumericExpression(visitor,expression,addParens)







    visitor.Head=visitor.Head+1;
    childHead=visitor.ChildrenHead;


    [funStr,numParens,isArgOrVar]=...
    compileNumericExpression@optim.internal.problemdef.visitor.CompileNonlinearFunction(...
    visitor,expression,addParens);
    isAllZero=false;
    singleLine=true;


    push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);




    visitor.ChildrenHead=childHead;
