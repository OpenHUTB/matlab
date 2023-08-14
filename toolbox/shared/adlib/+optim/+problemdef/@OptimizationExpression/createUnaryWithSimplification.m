function eout=createUnaryWithSimplification(ExprLeft,Op)












    eout=optim.problemdef.OptimizationExpression([]);



    createUnaryWithSimplification(eout.OptimExprImpl,Op,ExprLeft.OptimExprImpl);


    eout.IndexNamesStore=ExprLeft.IndexNames;
