function visitOperatorStaticSubsref(visitor,Op,Node)






    addParens=Inf;

    [leftJacName,leftJacParens]=getChildJacArgumentName(...
    visitor,1,addParens);


    addParens=1;
    [linIdxStr,linIdxParens,linIdxBody]=compileStaticLinIdxString(visitor,Op,addParens);


    linIdxStr="(:, "+linIdxStr+")";


    jacStr=leftJacName+linIdxStr;
    jacNumParens=leftJacParens+linIdxParens+1;
    jacIsArgOrVar=false;
    jacIsAllZero=false;
    visitor.ExprAndJacBody=visitor.ExprAndJacBody+linIdxBody;


    visitOperatorStaticSubsref@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,Op,Node);


    pushJac(visitor,jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);

end
