function visitUnaryOperator(visitor,op,~)




    [bLeft,ALeft]=popChild(visitor,1);

    Aval=evaluate(op,ALeft,[],visitor);
    bval=evaluate(op,bLeft,[],visitor);


    push(visitor,Aval,bval);

end
