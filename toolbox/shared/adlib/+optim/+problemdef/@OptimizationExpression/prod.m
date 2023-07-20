function eout=prod(obj,dim)




















    if nargin==1
        dim=[];
    end

    Op=optim.internal.problemdef.operator.Prod(obj,dim);
    eout=createUnary(obj,Op);