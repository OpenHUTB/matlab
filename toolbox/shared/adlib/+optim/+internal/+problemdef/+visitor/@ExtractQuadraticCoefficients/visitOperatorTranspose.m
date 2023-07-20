function visitOperatorTranspose(visitor,op,~)




    [bLeft,ALeft,HLeft]=popChild(visitor,1);

    NewIdxOrder=getLinearIdx(op);

    [Aval,bval]=visitOperatorTransposeWithIndex(visitor,ALeft,bLeft,NewIdxOrder);

    if nnz(HLeft)>0
        nVar=size(HLeft,2);

        Hidx=(1:nVar)'+(NewIdxOrder(:)'-1)*nVar;
        nElem=numel(Hidx);
        Mat=sparse(1:nElem,Hidx,ones(1,nElem),nElem,nElem);
        Hval=Mat*HLeft;
    else
        Hval=[];
    end


    push(visitor,Aval,bval);
    pushH(visitor,Hval);

end
