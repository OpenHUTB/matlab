function visitOperatorMpower(visitor,op,Node)






    leftVarName=declareChildArgumentName(visitor,1);
    leftIsAllZero=isChildAllZero(visitor,1);


    exponent=op.Exponent;

    if op.ExponentIsOptimExpr



        addParens=Inf;
        [exponentName,expParens]=compileNumericExpression(visitor,exponent,addParens);
    else

        exponentName=string(op.Exponent);
        expParens=0;
    end


    visitOperatorMpower@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,op,Node);




    if leftIsAllZero

        pushJacAllZeros(visitor,numel(Node));
        return;
    end


    FileNameMatrixIntegerPower="Mpower2DMatrixIntegerPower";
    jacStr=...
    FileNameMatrixIntegerPower+"("+leftVarName+", "+exponentName+")";
    jacParens=expParens+1;


    PackageLocation="optim.problemdef.gradients.mpower";


    pushTangentString(visitor,jacStr,jacParens,Node,PackageLocation);

end
