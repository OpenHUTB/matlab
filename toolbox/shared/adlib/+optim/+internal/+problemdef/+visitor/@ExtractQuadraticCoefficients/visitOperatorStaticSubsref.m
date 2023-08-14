function visitOperatorStaticSubsref(visitor,Op,~)





    [bLeft,ALeft,HLeft]=popChild(visitor,1);


    linIdx=getLinIndex(Op,Op.LhsSize,visitor);

    if nnz(HLeft)>0
        nVar=visitor.TotalVar;

        Hidx=(1:nVar)'+(linIdx(:)'-1)*nVar;
        Hval=HLeft(Hidx,:);
    else
        Hval=[];
    end

    if nnz(ALeft)>0
        Aval=ALeft(:,linIdx);
    else
        Aval=[];
    end
    bval=bLeft(linIdx(:));


    push(visitor,Aval,bval);
    pushH(visitor,Hval);

end
