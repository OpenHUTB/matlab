function eout=acsch(obj)







    Op=optim.internal.problemdef.operator.Acsch.getAcschOperator(obj);
    eout=createUnary(obj,Op);

end