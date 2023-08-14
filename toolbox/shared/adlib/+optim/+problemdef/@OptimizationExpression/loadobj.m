function eout=loadobj(ein)








    if ein.OptimizationExpressionVersion==1
        eout=optim.problemdef.OptimizationExpression([]);
        eout=reloadv1tov2(eout,ein);
    else
        eout=ein;
    end
