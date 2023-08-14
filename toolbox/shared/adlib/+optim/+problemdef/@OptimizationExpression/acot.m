function eout=acot(obj)







    Op=optim.internal.problemdef.operator.Acot.getAcotOperator(obj);
    eout=createUnary(obj,Op);

end