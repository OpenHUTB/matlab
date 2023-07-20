function visitOperatorStaticSubsref(visitor,Op,~)




    [bLeft,ALeft]=popChild(visitor,1);


    linIdx=getLinIndex(Op,Op.LhsSize,visitor);


    if nnz(ALeft)>0
        Aval=ALeft(:,linIdx);
    else
        Aval=[];
    end
    bval=bLeft(linIdx(:));


    push(visitor,Aval,bval);

end
