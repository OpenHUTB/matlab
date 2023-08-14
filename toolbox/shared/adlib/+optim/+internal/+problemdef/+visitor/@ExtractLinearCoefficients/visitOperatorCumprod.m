function visitOperatorCumprod(visitor,op,~)




    bLeft=popChild(visitor,1);


    Aval=[];
    bval=evaluate(op,reshape(bLeft,op.InputSize),[],visitor);
    bval=bval(:);


    push(visitor,Aval,bval);


end
