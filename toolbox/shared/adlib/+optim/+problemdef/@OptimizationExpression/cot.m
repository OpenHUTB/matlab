function eout=cot(obj)







    Op=optim.internal.problemdef.operator.Cot.getCotOperator(obj);
    eout=createUnary(obj,Op);

end