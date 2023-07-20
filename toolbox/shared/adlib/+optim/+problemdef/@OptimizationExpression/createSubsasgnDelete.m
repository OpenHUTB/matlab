function eout=createSubsasgnDelete(ExprLeft,sub)












    oldSz=size(ExprLeft);
    oldIdxNames=ExprLeft.IndexNames;



    [outSize,linIdx,outIdxNames]=optim.internal.problemdef.indexing.getSubsasgnDeleteOutputs(sub,oldSz,oldIdxNames);


    eout=optim.problemdef.OptimizationExpression([]);



    createSubsasgnDelete(eout.OptimExprImpl,ExprLeft.OptimExprImpl,linIdx,outSize);


    eout.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(...
    outIdxNames,outSize);
