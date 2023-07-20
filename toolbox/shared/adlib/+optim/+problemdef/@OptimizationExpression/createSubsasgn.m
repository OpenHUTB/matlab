function eout=createSubsasgn(ExprLeft,sub,exprRHS)













    oldSz=size(ExprLeft);
    oldIdxNames=ExprLeft.IndexNames;



    [outSize,linIdx,outIdxNames,subOutSize]=optim.internal.problemdef.indexing.getSubsasgnOutputs(sub,oldSz,oldIdxNames);


    linearIndexing=numel(sub(1).subs)==1;
    optim.internal.problemdef.indexing.checkValidRHSForSubsasgn(subOutSize,size(exprRHS),linearIndexing);


    eout=optim.problemdef.OptimizationExpression([]);



    createSubsasgn(eout.OptimExprImpl,ExprLeft.OptimExprImpl,linIdx,exprRHS.OptimExprImpl,outSize);


    eout.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(...
    outIdxNames,outSize);
