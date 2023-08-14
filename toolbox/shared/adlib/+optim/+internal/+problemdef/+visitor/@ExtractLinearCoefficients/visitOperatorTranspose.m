function visitOperatorTranspose(visitor,op,~)




    [bLeft,ALeft]=popChild(visitor,1);

    NewIdxOrder=getLinearIdx(op);
    [Aval,bval]=visitOperatorTransposeWithIndex(visitor,ALeft,bLeft,NewIdxOrder);


    push(visitor,Aval,bval);

end
