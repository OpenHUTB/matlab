function eout=tanh(obj)







    Op=optim.internal.problemdef.operator.Tanh.getTanhOperator(obj);
    eout=createUnary(obj,Op);

end