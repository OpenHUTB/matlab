function visitOperatorPlus(visitor,~,Node)





    jacIsAllZero=isParentJacAllZero(visitor);
    if jacIsAllZero

        visitor.Head=visitor.Head-1;
        pushAllZeroChild(visitor,1,Node.ExprLeft);
        pushAllZeroChild(visitor,2,Node.ExprRight);
        return;
    end





    addParens=Inf;
    [jacVarName,jacParens,jacIsArgOrVar]=getParentJacArgumentName(visitor,addParens);


    leftJac=jacVarName;
    leftJacParens=jacParens;
    leftJacIsArgOrVar=jacIsArgOrVar;
    leftJacIsAllZero=jacIsAllZero;

    rightJac=jacVarName;
    rightJacParens=jacParens;
    rightJacIsArgOrVar=jacIsArgOrVar;
    rightJacIsAllZero=jacIsAllZero;


    ExprLeft=Node.ExprLeft;
    ExprRight=Node.ExprRight;

    compileJacScalarExpansion(visitor,1,ExprLeft,ExprRight,...
    leftJac,leftJacParens,leftJacIsArgOrVar,leftJacIsAllZero);
    compileJacScalarExpansion(visitor,2,ExprRight,ExprLeft,...
    rightJac,rightJacParens,rightJacIsArgOrVar,rightJacIsAllZero);

end
