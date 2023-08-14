function visitOperatorSum(visitor,op,Node)




    [~,~,HLeft]=popChild(visitor,1);


    visitOperatorSum@optim.internal.problemdef.visitor.ExtractLinearCoefficients(...
    visitor,op,Node);


    if matlab.internal.datatypes.isScalarText(op.Dimension)
        if nnz(HLeft)>0
            nElem=prod(op.LeftSize);
            nVar=size(HLeft,2);
            SMat=repmat(speye(nVar),1,nElem);
            Hval=SMat*HLeft;
        else
            Hval=[];
        end
        pushH(visitor,Hval);
        return;
    end


    dimi=op.Dimension;
    LDims=op.LeftSize;

    outDims=LDims;
    outDims(dimi)=1;
    tempProd=prod(outDims(1:dimi));
    if dimi>numel(LDims)
        Hval=HLeft;
        pushH(visitor,Hval);
        return;
    end

    if nnz(HLeft)>0

        nVar=size(HLeft,2);
        C=repmat(speye(nVar*tempProd),1,LDims(dimi));
        n=prod(outDims(dimi+1:end));
        SMat=kron(speye(n),C);
        Hval=SMat*HLeft;
    else
        Hval=[];
    end


    pushH(visitor,Hval);

end
