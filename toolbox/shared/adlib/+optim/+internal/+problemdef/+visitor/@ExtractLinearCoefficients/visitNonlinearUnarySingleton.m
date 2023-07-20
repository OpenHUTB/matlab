function visitNonlinearUnarySingleton(visitor,op,~)




    bLeft=popChild(visitor,1);


    Aval=[];
    bval=evaluate(op,bLeft,[],visitor);


    push(visitor,Aval,bval);

end
