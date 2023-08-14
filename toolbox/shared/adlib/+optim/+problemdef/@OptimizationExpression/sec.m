function eout=sec(obj)







    Op=optim.internal.problemdef.operator.Sec.getSecOperator(obj);
    eout=createUnary(obj,Op);

end