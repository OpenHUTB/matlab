function eout=power(obj,b)











    Op=optim.internal.problemdef.Power(obj,b);
    if isa(b,"optim.problemdef.OptimizationExpression")
        eout=createUnary(obj,Op);
    elseif b==0

        eout=optim.problemdef.OptimizationNumeric(ones(size(obj)));
    elseif b==1

        eout=optim.problemdef.OptimizationExpression(obj);
    else

        eout=createUnaryWithSimplification(obj,Op);
    end
