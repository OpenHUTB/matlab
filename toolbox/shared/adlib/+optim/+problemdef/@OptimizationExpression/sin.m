function eout=sin(obj)







    Op=optim.internal.problemdef.operator.Sin.getSinOperator(obj);
    eout=createUnary(obj,Op);

end