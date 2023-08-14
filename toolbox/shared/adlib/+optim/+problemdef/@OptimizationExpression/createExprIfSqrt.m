function[isqrt,eout,const,fac]=createExprIfSqrt(expr)















    eout=optim.problemdef.OptimizationExpression([]);



    [isqrt,const,fac]=createExprIfSqrt(eout.OptimExprImpl,expr.OptimExprImpl);


    if~isqrt
        eout=expr;
    end