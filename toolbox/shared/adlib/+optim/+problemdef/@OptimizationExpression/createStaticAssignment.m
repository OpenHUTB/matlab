function eout=createStaticAssignment(ExprLeft,ExprRight,Op,PtiesVisitor)













    eout=optim.problemdef.OptimizationExpression([]);



    createStaticAssignment(eout.OptimExprImpl,Op,...
    ExprLeft.OptimExprImpl,ExprRight.OptimExprImpl,PtiesVisitor);


    eout.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(...
    getOutputIndexNames(Op,ExprLeft,ExprRight),size(eout.OptimExprImpl));
