function eout=asech(obj)







    Op=optim.internal.problemdef.operator.Asech.getAsechOperator(obj);
    eout=createUnary(obj,Op);

end