function eout=sinh(obj)







    Op=optim.internal.problemdef.operator.Sinh.getSinhOperator(obj);
    eout=createUnary(obj,Op);

end