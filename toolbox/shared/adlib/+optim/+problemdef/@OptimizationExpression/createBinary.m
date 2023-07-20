function eout=createBinary(ExprLeft,ExprRight,Op)











    eout=optim.problemdef.OptimizationExpression([]);



    createBinary(eout.OptimExprImpl,Op,ExprLeft.OptimExprImpl,ExprRight.OptimExprImpl);


    eout.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(...
    getOutputIndexNames(Op,ExprLeft,ExprRight),size(eout.OptimExprImpl));
