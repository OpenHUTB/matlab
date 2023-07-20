function storeWithSubsasgn(visitor,forestSize)





    jacOutname=visitor.ForestJacName;
    jacNumParens=0;
    jacIsArgOrVar=true;
    jacIsAllZero=visitor.ForestJacIsAllZero;


    if jacIsAllZero

        storeWithSubsasgn@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,forestSize);

        pushJacAllZeros(visitor,prod(forestSize));
        return;
    end


    jacSize=[visitor.TotalVar,prod(forestSize)];
    zeroStr=...
    optim.internal.problemdef.ZeroExpressionImpl.getNonlinearStr(jacSize);
    visitor.ExprAndJacBody=jacOutname+" = "+zeroStr+";"+newline+visitor.ExprAndJacBody;


    forestJacName=visitor.ForestJacName;
    jacSize=[visitor.TotalVar,prod(forestSize)];
    [jacOutname,jacNumParens,jacIsArgOrVar,~,forestJacBody]=visitor.reshapeInputStr(...
    forestJacName,jacSize,jacOutname,jacNumParens,jacIsArgOrVar);


    visitor.ExprAndJacBody=visitor.ExprAndJacBody+forestJacBody;


    storeWithSubsasgn@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,forestSize);


    pushJac(visitor,jacOutname,jacNumParens,jacIsArgOrVar,jacIsAllZero);

end
