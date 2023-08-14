function eout=createUnary(ExprLeft,Op,sub)









    if nargin<3
        sub=[];
    end


    eout=optim.problemdef.OptimizationExpression([]);



    createUnary(eout.OptimExprImpl,Op,ExprLeft.OptimExprImpl);


    eout.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(...
    getOutputIndexNames(Op,ExprLeft,sub),size(eout.OptimExprImpl));
