function eout=acos(obj)







    Op=optim.internal.problemdef.operator.Acos.getAcosOperator(obj);
    eout=createUnary(obj,Op);

end