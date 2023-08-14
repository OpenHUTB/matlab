function visitOperatorSum(visitor,op,Node)







    leftJacIsAllZero=isChildJacAllZero(visitor,1);
    if leftJacIsAllZero

        visitOperatorSum@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,op,Node);

        pushJacAllZeros(visitor,numel(Node));
        return;
    end


    addParens=1;
    [leftJacVarName,leftJacParens,leftIsArgOrVar]=getChildJacArgumentName(...
    visitor,1,addParens);


    if matlab.internal.datatypes.isScalarText(op.Dimension)

        visitOperatorSum@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,op,Node);
        jacStr="sum("+leftJacVarName+",2)";
        jacNumParens=leftJacParens+1;
        jacIsArgOrVar=false;
        pushJac(visitor,jacStr,jacNumParens,jacIsArgOrVar,leftJacIsAllZero);
        return;
    end



    dimi=op.Dimension;
    LDims=op.LeftSize;


    if dimi>numel(LDims)
        jacStr=leftJacVarName;
        jacNumParens=leftJacParens;
        jacIsArgOrVar=leftIsArgOrVar;
    else

        [SMat,visitor.ExprAndJacBody]=visitor.createSumSMatString(visitor.ExprAndJacBody,LDims,dimi);

        jacStr="("+leftJacVarName+"*"+SMat+")";
        jacNumParens=leftJacParens+1;
        jacIsArgOrVar=false;
    end



    visitOperatorSum@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,op,Node);


    pushJac(visitor,jacStr,jacNumParens,jacIsArgOrVar,leftJacIsAllZero);

end
