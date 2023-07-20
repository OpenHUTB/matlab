function eout=acoth(obj)







    Op=optim.internal.problemdef.operator.Acoth.getAcothOperator(obj);
    eout=createUnary(obj,Op);

end