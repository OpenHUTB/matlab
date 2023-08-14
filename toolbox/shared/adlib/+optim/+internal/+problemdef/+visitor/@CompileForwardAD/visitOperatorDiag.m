function visitOperatorDiag(visitor,op,Node)






    leftVarName=declareChildArgumentName(visitor,1);
    leftJacIsAllZero=isChildJacAllZero(visitor,1);


    visitOperatorDiag@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,op,Node);

    if leftJacIsAllZero

        pushJacAllZeros(visitor,numel(Node));
    else

        LeftExpr=Node.ExprLeft;


        addParens=1;

        [leftJacVarName,leftJacParens]=getChildJacArgumentName(...
        visitor,1,addParens);

        if isvector(LeftExpr)

            tanStr="DiagVectorInputTangent("+...
            leftVarName+", "+leftJacVarName+", "+op.DiagK+")";
        else

            Nout=op.OutputSize(1);
            tanStr="Diag2DMatrixInputTangent("+...
            leftVarName+", "+leftJacVarName+", "+op.DiagK+", "+Nout+")";
        end

        tanNumParens=leftJacParens+1;
        tanIsArgOrVar=false;
        tanIsAllZero=false;

        pushJac(visitor,tanStr,tanNumParens,tanIsArgOrVar,tanIsAllZero);


        PackageLocation="optim.problemdef.gradients.diag";
        visitor.PkgDepends(end+1)=PackageLocation;
    end

end
