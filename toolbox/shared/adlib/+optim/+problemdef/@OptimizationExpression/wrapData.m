function eout=wrapData(data)






    if~isa(data,'optim.problemdef.OptimizationExpression')

        eout=optim.problemdef.OptimizationExpression([]);




        createNumeric(eout.OptimExprImpl,data);
    else


        eout=data;
    end
