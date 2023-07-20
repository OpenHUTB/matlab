function visitOperatorPlus(visitor,op,Node)





    visitOperatorPlus@optim.internal.problemdef.visitor.CompileNonlinearFunction(...
    visitor,op,Node);


    leftJacAllZero=isChildJacAllZero(visitor,1);
    rightJacAllZero=isChildJacAllZero(visitor,2);

    if leftJacAllZero
        if rightJacAllZero

            pushJacAllZeros(visitor,numel(Node));
        else

            childIdx=2;
            compileJacScalarExpansion(visitor,childIdx,Node.ExprRight,Node.ExprLeft);
        end
    elseif rightJacAllZero

        childIdx=1;
        compileJacScalarExpansion(visitor,childIdx,Node.ExprLeft,Node.ExprRight);
    else

        compileJacOperator(visitor,op,Node);
    end

end
