function eout=atan(obj)







    Op=optim.internal.problemdef.operator.Atan.getAtanOperator(obj);
    eout=createUnary(obj,Op);

end