function eout=diag(obj,k)

















    if nargin<2
        k=0;
    end
    Op=optim.internal.problemdef.operator.Diag(size(obj),k);
    eout=createUnary(obj,Op);

end