function eout=colon(first,step,last)
















    if nargin<3
        last=step;
        step=1;
    end


    eout=optim.problemdef.OptimizationExpression([]);

    createColon(eout.OptimExprImpl,first,step,last);


    eout.IndexNamesStore=optim.internal.problemdef.makeValidIndexNames(...
    {{},{}},size(eout.OptimExprImpl));

end