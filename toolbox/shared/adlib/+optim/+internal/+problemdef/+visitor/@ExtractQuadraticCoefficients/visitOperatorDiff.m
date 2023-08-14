function visitOperatorDiff(visitor,op,Node)




    [bLeft,ALeft,HLeft]=popChild(visitor,1);

    if nnz(HLeft)==0
        visitOperatorDiff@optim.internal.problemdef.visitor.ExtractLinearCoefficients(...
        visitor,op,Node);
        Hval=[];
        pushH(visitor,Hval);
        return;
    end


    N=op.Order;
    dim=op.Dim;
    outSz=op.InputSize;
    nvar=size(HLeft,2);


    [Jacobian,Hmat]=...
    optim.problemdef.gradients.diff.DiffJacobian(outSz,N,dim,nvar);

    ndims=numel(outSz);

    outSz=[outSz,ones(1,dim-ndims)];
    if(~isempty(dim)&&N>=outSz(dim))
        Hval=[];
        Aval=[];
        outSz(dim)=0;
        bval=zeros(outSz);
    elseif isempty(Jacobian)
        Hval=[];
        Aval=[];
        bval=[];
    else
        if isempty(dim)
            Hval=Hmat*HLeft;
        else
            Hval=kron(Hmat,speye(size(HLeft,2)))*HLeft;
        end


        bval=full(Jacobian*bLeft(:));
        if nnz(ALeft)>0
            Aval=ALeft*Jacobian.';
        else
            Aval=[];
        end
    end


    push(visitor,Aval,bval);
    pushH(visitor,Hval);

end
