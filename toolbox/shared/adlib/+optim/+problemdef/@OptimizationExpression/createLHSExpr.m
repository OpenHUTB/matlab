function[eout,LHSExprImpl]=createLHSExpr(lhsName,ptiesVisitor)








    eout=optim.problemdef.OptimizationExpression([]);



    LHSExprImpl=createLHSExpression(eout.OptimExprImpl,lhsName);
    initializeNode(ptiesVisitor,LHSExprImpl);


    eout.IndexNamesStore={{},{}};
