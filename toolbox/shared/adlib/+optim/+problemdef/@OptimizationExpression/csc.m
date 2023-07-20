function eout=csc(obj)





    Op=optim.internal.problemdef.operator.Csc.getCscOperator(obj);
    eout=createUnary(obj,Op);

end
