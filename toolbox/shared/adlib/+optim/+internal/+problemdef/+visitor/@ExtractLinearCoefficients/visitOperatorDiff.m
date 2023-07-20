function visitOperatorDiff(visitor,op,~)




    [bLeft,ALeft]=popChild(visitor,1);


    N=op.Order;
    dim=op.Dim;
    outSz=op.InputSize;


    Jacobian=optim.problemdef.gradients.diff.DiffJacobian(outSz,N,dim,[]);

    ndims=numel(outSz);

    outSz=[outSz,ones(1,dim-ndims)];
    if(~isempty(dim)&&N>=outSz(dim))
        Aval=[];
        outSz(dim)=0;
        bval=zeros(outSz);
    elseif isempty(Jacobian)
        Aval=[];
        bval=[];
    else

        bval=full(Jacobian*bLeft(:));
        if nnz(ALeft)>0
            Aval=ALeft*Jacobian.';
        else
            Aval=[];
        end
    end


    push(visitor,Aval,bval);

end
