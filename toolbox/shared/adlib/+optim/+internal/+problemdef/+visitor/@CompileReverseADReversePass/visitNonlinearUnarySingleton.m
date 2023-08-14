function visitNonlinearUnarySingleton(visitor,op,Node)





    leftVarName=getForwardMemory(visitor);


    jacIsAllZero=isParentJacAllZero(visitor);
    if jacIsAllZero

        visitor.Head=visitor.Head-1;
        pushAllZeroChild(visitor,1,Node.ExprLeft);
        return;
    end




    [gradStr,addParens]=getGradientString(op,leftVarName);


    [jacVarName,jacParens]=getParentJacArgumentName(visitor,addParens);






    leftJac="("+jacVarName+gradStr+")";
    leftJacParens=jacParens+addParens+1;
    leftJacIsArgOrVar=false;
    leftJacIsAllZero=false;


    push(visitor,leftJac,leftJacParens,leftJacIsArgOrVar,leftJacIsAllZero);

end
