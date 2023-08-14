function eout=acosh(obj)







    Op=optim.internal.problemdef.operator.Acosh.getAcoshOperator(obj);
    eout=createUnary(obj,Op);

end