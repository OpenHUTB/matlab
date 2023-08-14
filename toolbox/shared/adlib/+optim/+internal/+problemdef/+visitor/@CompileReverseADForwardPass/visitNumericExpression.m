function[funStr,numParens,isArgOrVar]=visitNumericExpression(visitor,expression,addParens)









    prevTape=visitor.Tape;
    prevWriteToArgTape=visitor.WriteToArgTape;
    [funStr,numParens,isArgOrVar]=...
    visitNumericExpression@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,expression,addParens);
    visitor.Tape=prevTape;
    visitor.WriteToArgTape=prevWriteToArgTape;


    head=visitor.Head;
    fixedVar=isFixedVar(visitor,head+1);
    if~fixedVar


        singleLine=true;
        addParens=Inf;
        [funStr,numParens,varBody]=addParensToArg(visitor,...
        funStr,numParens,isArgOrVar,singleLine,addParens);
        if dependsOnLoopVar(visitor,head+1)
            addToExprBody(visitor,varBody);
        else
            addToPreLoopBody(visitor,varBody);
        end
    end
    storeForwardMemoryRAD(visitor,funStr,fixedVar);

    fixedVar=true;
    storeForwardMemoryRAD(visitor,numParens,fixedVar);
