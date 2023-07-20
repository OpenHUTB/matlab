function[H,A,b]=extractQuadraticCoefficients(expr,TotalVar)













    if nargin<2

        TotalVar=optim.problemdef.OptimizationVariable.setVariableOffset(expr.Variables);
    end

    [H,A,b]=extractQuadraticCoefficients(expr.OptimExprImpl,TotalVar);


end
