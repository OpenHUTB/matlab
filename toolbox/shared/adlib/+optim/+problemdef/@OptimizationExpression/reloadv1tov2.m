function eout=reloadv1tov2(eout,ein)









    eout.IndexNamesStore=ein.IndexNames;


    forest=optim.internal.problemdef.ExpressionForest;
    tree2forest(forest,ein.OptimExprImpl);
    eout.OptimExprImpl=forest;