function eout=createForLoop(loopVariable,loopRange,loopBody,loopLevel,PtiesVisitor)


















    eout=optim.problemdef.OptimizationExpression([]);

    createForLoop(eout.OptimExprImpl,loopVariable.OptimExprImpl,...
    loopRange,loopBody,loopLevel,PtiesVisitor);


    eout.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(...
    {{},{}},size(eout.OptimExprImpl));
