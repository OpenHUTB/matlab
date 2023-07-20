function eout=mpower(obj,b)









    if isscalar(obj)

        eout=power(obj,b);
    else


        Op=optim.internal.problemdef.Mpower(obj,b);
        if isa(b,"optim.problemdef.OptimizationExpression")
            eout=createUnary(obj,Op);
        elseif b==0

            eout=optim.problemdef.OptimizationNumeric(speye(size(obj)));
        elseif b==1

            eout=optim.problemdef.OptimizationExpression(obj);
        else

            eout=createUnaryWithSimplification(obj,Op);
        end
    end
