function eout=atanh(obj)







    Op=optim.internal.problemdef.operator.Atanh.getAtanhOperator(obj);
    eout=createUnary(obj,Op);

end