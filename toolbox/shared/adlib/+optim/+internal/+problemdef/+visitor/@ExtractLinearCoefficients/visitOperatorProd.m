function visitOperatorProd(visitor,op,~)




    bLeft=popChild(visitor,1);


    Aval=[];
    bval=evaluate(op,reshape(bLeft,op.LeftSize),[],visitor);
    bval=bval(:);


    push(visitor,Aval,bval);

end
