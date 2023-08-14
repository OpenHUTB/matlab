function visitOperatorDiag(visitor,op,Node)







    leftVarName=getForwardMemory(visitor);


    diagK=op.DiagK;

    jacIsAllZero=isParentJacAllZero(visitor);
    if jacIsAllZero

        visitor.Head=visitor.Head-1;
        pushJacAllZeros(visitor,numel(Node.ExprLeft));
    else

        LeftExpr=Node.ExprLeft;

        addParens=1;
        [dirStr,dirParens]=getParentJacArgumentName(visitor,addParens);

        if isvector(LeftExpr)

            adjStr="DiagVectorInputAdjoint("+...
            leftVarName+", "+dirStr+", "+diagK+")";
        else

            Nout=op.OutputSize(1);
            adjStr="Diag2DMatrixInputAdjoint("+...
            leftVarName+", "+dirStr+", "+diagK+", "+Nout+")";
        end

        adjParens=dirParens+1;
        adjIsArgOrVar=false;
        adjIsAllZero=false;

        push(visitor,adjStr,adjParens,adjIsArgOrVar,adjIsAllZero);


        PackageLocation="optim.problemdef.gradients.diag";
        visitor.PkgDepends(end+1)=PackageLocation;
    end

end
