function visitOperatorTimes(visitor,~,Node)





    [rightIsAllZero,rightVarName]=getChildMemory(visitor);
    [leftIsAllZero,leftVarName]=getChildMemory(visitor);


    jacIsAllZero=isParentJacAllZero(visitor);
    if jacIsAllZero

        visitor.Head=visitor.Head-1;
        pushAllZeroChild(visitor,1,Node.ExprLeft);
        pushAllZeroChild(visitor,2,Node.ExprRight);
        return;
    end





    addParens=Inf;
    [jacVarName,jacParens]=getParentJacArgumentName(visitor,addParens);


    ExprLeft=Node.ExprLeft;
    ExprRight=Node.ExprRight;

    if rightIsAllZero

        pushAllZeroChild(visitor,1,ExprLeft);
    else

        leftJac="("+jacVarName+".*"+rightVarName+"(:))";
        leftJacParens=jacParens+2;
        leftJacIsArgOrVar=false;
        leftJacIsAllZero=false;
        compileJacScalarExpansion(visitor,1,ExprLeft,ExprRight,...
        leftJac,leftJacParens,leftJacIsArgOrVar,leftJacIsAllZero);
    end

    if leftIsAllZero

        pushAllZeroChild(visitor,2,ExprRight);
    else

        rightJac="("+jacVarName+".*"+leftVarName+"(:))";
        rightJacParens=jacParens+2;
        rightJacIsArgOrVar=false;
        rightJacIsAllZero=false;
        compileJacScalarExpansion(visitor,2,ExprRight,ExprLeft,...
        rightJac,rightJacParens,rightJacIsArgOrVar,rightJacIsAllZero);
    end

end


