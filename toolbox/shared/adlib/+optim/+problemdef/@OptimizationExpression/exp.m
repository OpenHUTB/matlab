function eout=exp(obj)







    Op=optim.internal.problemdef.operator.Exp.getExpOperator(obj);
    eout=createUnary(obj,Op);

end