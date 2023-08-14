function visitOperatorPower(visitor,op,Node)






    leftVarName=declareChildArgumentName(visitor,1);
    leftIsAllZero=isChildAllZero(visitor,1);


    exponent=op.Exponent;

    if op.ExponentIsOptimExpr



        addParens=Inf;
        [exponentName,expParens]=compileNumericExpression(visitor,exponent,addParens);
    end


    visitOperatorPower@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,op,Node);


    leftJacIsAllZero=isChildJacAllZero(visitor,1);
    if(leftIsAllZero||leftJacIsAllZero)&&exponent>0

        pushJacAllZeros(visitor,numel(Node));
        return;
    end



    addParens=3;
    [leftJacVarName,leftJacParens]=getChildJacArgumentName(...
    visitor,1,addParens);


    if op.ExponentIsOptimExpr
        jacStr="("+exponentName+".* reshape("+leftVarName+", 1, [])"+...
        op.OperatorStr+"("+exponentName+"-1))"+".*"+leftJacVarName;
        leftJacParens=leftJacParens+3+expParens;
    elseif exponent==2

        jacStr="(2 .* "+leftVarName+"(:).'.*"+leftJacVarName+")";
        leftJacParens=leftJacParens+2;
    elseif op.integerExponent

        jacStr="("+exponent+".* "+leftVarName+"(:).'"+...
        op.OperatorStr+(exponent-1)+")"+".*"+leftJacVarName;
        leftJacParens=leftJacParens+2;
    else

        exponentName=visitor.ExtraParams{end};
        jacStr="("+exponentName+".* "+leftVarName+"(:).'"+...
        op.OperatorStr+"("+exponentName+"-1))"+".*"+leftJacVarName;
        leftJacParens=leftJacParens+3;
    end

    jacNumParens=leftJacParens;
    jacIsArgOrVar=false;
    jacIsAllZero=false;
    pushJac(visitor,jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);

end
