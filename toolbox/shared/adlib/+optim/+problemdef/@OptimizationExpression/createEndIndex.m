function eout=createEndIndex()







    eout=optim.problemdef.OptimizationExpression([]);



    createEndIndex(eout.OptimExprImpl);


    eout.IndexNamesStore={{},{}};
