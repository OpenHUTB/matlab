function eout=tan(obj)







    Op=optim.internal.problemdef.operator.Tan.getTanOperator(obj);
    eout=createUnary(obj,Op);

end