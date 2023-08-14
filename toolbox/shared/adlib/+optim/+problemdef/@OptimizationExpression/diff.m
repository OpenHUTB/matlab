function eout=diff(obj,N,dim)
















    if nargin<3
        dim=[];
        if nargin<2
            N=[];
        end
    elseif isempty(dim)
        error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
    end

    Op=optim.internal.problemdef.operator.Diff(size(obj),N,dim);
    eout=createUnary(obj,Op);

end