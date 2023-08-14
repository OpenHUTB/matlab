function eout=csch(obj)





    Op=optim.internal.problemdef.operator.Csch.getCschOperator(obj);
    eout=createUnary(obj,Op);

end
