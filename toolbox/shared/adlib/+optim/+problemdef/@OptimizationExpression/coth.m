function eout=coth(obj)







    Op=optim.internal.problemdef.operator.Coth.getCothOperator(obj);
    eout=createUnary(obj,Op);

end