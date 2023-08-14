function eout=sech(obj)







    Op=optim.internal.problemdef.operator.Sech.getSechOperator(obj);
    eout=createUnary(obj,Op);

end