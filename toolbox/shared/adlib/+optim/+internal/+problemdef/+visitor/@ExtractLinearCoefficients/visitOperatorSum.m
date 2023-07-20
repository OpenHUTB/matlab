function visitOperatorSum(visitor,op,~)




    [bLeft,ALeft]=popChild(visitor,1);


    if matlab.internal.datatypes.isScalarText(op.Dimension)
        Aval=sum(ALeft,2);
        bval=sum(bLeft);

        push(visitor,Aval,bval);
        return;
    end


    dimi=op.Dimension;
    LDims=op.LeftSize;


    if dimi>numel(LDims)
        Aval=ALeft;
        bval=bLeft;

        push(visitor,Aval,bval);
        return;
    end

    outDims=LDims;
    outDims(dimi)=1;

    tempProd=prod(outDims(1:dimi));
    C=repmat(speye(tempProd),LDims(dimi),1);
    n=prod(outDims(dimi+1:end));
    SMat=kron(speye(n),C);

    if nnz(ALeft)>0
        Aval=ALeft*SMat;
    else
        Aval=[];
    end
    bval=bLeft'*SMat;
    bval=full(bval(:));


    push(visitor,Aval,bval);

end
