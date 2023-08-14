function visitOperatorMinus(visitor,op,Node)





    visitOperatorMinus@optim.internal.problemdef.visitor.CompileNonlinearFunction(...
    visitor,op,Node);


    leftJacAllZero=isChildJacAllZero(visitor,1);
    rightJacAllZero=isChildJacAllZero(visitor,2);

    if leftJacAllZero
        if rightJacAllZero

            pushJacAllZeros(visitor,numel(Node));
        else

            childIdx=2;
            compileJacScalarExpansion(visitor,childIdx,Node.ExprRight,Node.ExprLeft);


            addParens=1;
            [jacName,jacParens]=getJacArgumentName(visitor,addParens);

            jacStr="(-"+jacName+")";
            jacParens=jacParens+1;
            jacIsArgOrVar=false;
            jacIsAllZero=false;
            pushJac(visitor,jacStr,jacParens,jacIsArgOrVar,jacIsAllZero);
        end
    elseif rightJacAllZero

        childIdx=1;
        compileJacScalarExpansion(visitor,childIdx,Node.ExprLeft,Node.ExprRight);
    else

        compileJacOperator(visitor,op,Node);
    end

end
