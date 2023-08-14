function eout=createUplus(ExprLeft)









    eout=optim.problemdef.OptimizationExpression([]);



    copy(eout.OptimExprImpl,ExprLeft.OptimExprImpl);


    eout.IndexNamesStore=ExprLeft.IndexNames;
