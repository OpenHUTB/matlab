function visitOperatorMpower(visitor,op,Node)









    if op.ExponentIsOptimExpr

        expParens=getForwardMemory(visitor);
        exponentName=getForwardMemory(visitor);
    else

        exponentName=string(op.Exponent);
        expParens=0;
    end


    [leftIsAllZero,leftVarName]=getChildMemory(visitor);


    if leftIsAllZero

        visitor.Head=visitor.Head-1;
        pushAllZeroChild(visitor,1,Node.ExprLeft);
        return;
    end

    FileNameMatrixIntegerPower="Mpower2DMatrixIntegerPower";
    jacStr=...
    FileNameMatrixIntegerPower+"("+leftVarName+", "+exponentName+")";
    jacParens=1+expParens;


    PackageLocation="optim.problemdef.gradients.mpower";


    pushAdjointString(visitor,jacStr,jacParens,Node,PackageLocation);

end
