function eout=asinh(obj)







    Op=optim.internal.problemdef.operator.Asinh.getAsinhOperator(obj);
    eout=createUnary(obj,Op);

end