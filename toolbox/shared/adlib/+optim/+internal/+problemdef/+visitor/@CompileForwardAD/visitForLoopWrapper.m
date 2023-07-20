function visitForLoopWrapper(visitor,LoopWrapper)





    loopVar=LoopWrapper.LoopVar;
    loopValues=LoopWrapper.LoopRange;
    loopBody=LoopWrapper.LoopBody;




    if isempty(loopVar.VisitorIndex)

        initializeLHS(visitor,loopVar);

        jacSize=[visitor.TotalVar,numel(loopVar)];
        [jacStr,jacNumParens]=...
        optim.internal.problemdef.ZeroExpressionImpl.getNonlinearSparseStr(jacSize);
        jacIsArgOrVar=false;
        jacIsAllZero=true;
        pushNodeJac(visitor,loopVar,jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);
    else




        pushNodeJacIsAllZero(visitor,loopVar,true);
    end
    loopVarName=popNode(visitor,loopVar);


    acceptVisitor(loopValues,visitor);
    loopValuesStr=pop(visitor);
    visitor.Head=visitor.Head-1;


    prevExprBody=visitor.ExprBody;
    prevExprAndJacBody=visitor.ExprAndJacBody;
    visitor.ExprBody="";
    visitor.ExprAndJacBody="";

    acceptVisitor(loopBody,visitor);


    forloopBody=visitor.ExprBody;
    exprAndjacloopBody=visitor.ExprAndJacBody;


    forloopBody=strjoin("    "+splitlines(strip(forloopBody,'right')),'\n')+newline;
    forloopBody="for "+loopVarName+" = "+loopValuesStr+newline+...
    forloopBody+...
    "end"+newline;

    exprAndjacloopBody=strjoin("    "+splitlines(strip(exprAndjacloopBody,'right')),'\n')+newline;
    exprAndjacloopBody="for "+loopVarName+" = "+loopValuesStr+newline+...
    exprAndjacloopBody+...
    "end"+newline;


    visitor.ExprBody=prevExprBody+forloopBody;
    visitor.ExprAndJacBody=prevExprAndJacBody+exprAndjacloopBody;

end
