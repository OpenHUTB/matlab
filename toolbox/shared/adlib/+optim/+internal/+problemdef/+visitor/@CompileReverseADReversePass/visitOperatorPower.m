function visitOperatorPower(visitor,op,Node)





    integerOp=integerExponent(op);
    if op.ExponentIsOptimExpr

        expParens=getForwardMemory(visitor);
        exponentName=getForwardMemory(visitor);
    elseif~integerOp

        exponentName=getForwardMemory(visitor);
    end


    [leftIsAllZero,leftVarName]=getChildMemory(visitor);


    exponent=op.Exponent;


    jacIsAllZero=isParentJacAllZero(visitor);
    if(jacIsAllZero||leftIsAllZero)&&exponent>0

        visitor.Head=visitor.Head-1;
        pushJacAllZeros(visitor,numel(Node.ExprLeft));
        return;
    end









    addParens=3;
    [jacVarName,jacParens]=getParentJacArgumentName(visitor,addParens);

    if op.ExponentIsOptimExpr
        leftJac="("+jacVarName+".*("+exponentName+".*"+...
        leftVarName+"(:)"+op.OperatorStr+"("+exponentName+"-1)))";
        leftJacParens=jacParens++expParens+4;
    elseif exponent==2

        leftJac="("+jacVarName+".*2.*("+leftVarName+"(:))"+")";
        leftJacParens=jacParens+2;
    elseif integerOp

        leftJac="("+jacVarName+".*("+exponent+".*"+...
        leftVarName+"(:)"+op.OperatorStr+(exponent-1)+"))";
        leftJacParens=jacParens+2;
    else
        leftJac="("+jacVarName+".*("+exponentName+".*"+...
        leftVarName+"(:)"+op.OperatorStr+"("+exponentName+"-1)))";
        leftJacParens=jacParens+4;
    end
    leftJacIsArgOrVar=false;
    leftJacIsAllZero=false;


    push(visitor,leftJac,leftJacParens,leftJacIsArgOrVar,leftJacIsAllZero);

end
