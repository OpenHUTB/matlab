function eout=createUnaryWithCancellation(ExprLeft,Op)












    eout=optim.problemdef.OptimizationExpression([]);



    createUnaryWithCancellation(eout.OptimExprImpl,Op,ExprLeft.OptimExprImpl);


    eout.IndexNamesStore=ExprLeft.IndexNames;
