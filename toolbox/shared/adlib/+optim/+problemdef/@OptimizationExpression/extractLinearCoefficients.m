function[A,b]=extractLinearCoefficients(expr,TotalVar)

















    if nargin<2

        TotalVar=optim.problemdef.OptimizationVariable.setVariableOffset(expr.Variables);
    end

    [A,b]=extractLinearCoefficients(expr.OptimExprImpl,TotalVar);


end
