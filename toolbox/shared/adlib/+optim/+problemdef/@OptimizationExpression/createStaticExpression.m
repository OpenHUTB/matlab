function eout=createStaticExpression(lhsExpr,stmtWrapper,type,vars)
















    if isempty(stmtWrapper)

        eout=lhsExpr;
        return;
    end


    eout=optim.problemdef.OptimizationExpression([]);

    createStaticExpression(eout.OptimExprImpl,lhsExpr.OptimExprImpl,stmtWrapper,type,vars);


    eout.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(...
    {{},{}},size(eout.OptimExprImpl));
