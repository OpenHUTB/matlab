function eout=cos(obj)







    Op=optim.internal.problemdef.operator.Cos.getCosOperator(obj);
    eout=createUnary(obj,Op);

end