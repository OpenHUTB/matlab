function[iss,eout,c,idx]=createExprIfSumSquares(expr)















    eout=optim.problemdef.OptimizationExpression([]);



    [iss,c,idx]=createExprIfSumSquares(eout.OptimExprImpl,expr.OptimExprImpl);


    if~iss
        eout=expr;
    end


