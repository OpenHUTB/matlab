function eout=acsc(obj)







    Op=optim.internal.problemdef.operator.Acsc.getAcscOperator(obj);
    eout=createUnary(obj,Op);

end