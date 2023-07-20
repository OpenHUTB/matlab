function eout=createSubsref(ExprLeft,sub)











    oldSz=size(ExprLeft);
    oldIdxNames=ExprLeft.IndexNames;


    [outSize,linIdx,outIdxNames]=optim.internal.problemdef.indexing.getSubsrefOutputs(sub,oldSz,oldIdxNames);


    eout=optim.problemdef.OptimizationExpression([]);



    createSubsref(eout.OptimExprImpl,ExprLeft.OptimExprImpl,linIdx,outSize);


    eout.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(...
    outIdxNames,outSize);
