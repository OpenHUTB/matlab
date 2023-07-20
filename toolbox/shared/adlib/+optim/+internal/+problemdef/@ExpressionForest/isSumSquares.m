function iss=isSumSquares(expr)




















    visitor=optim.internal.problemdef.visitor.IsSumSquares;
    visitForest(visitor,expr);
    iss=getOutputs(visitor);
