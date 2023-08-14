function expr=createFunction(expr,optimFunc,vars,depth,outSize,type,index)















    createFunction(expr.OptimExprImpl,optimFunc,vars,depth,outSize,type,index);


    expr.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(...
    {{},{}},outSize);
