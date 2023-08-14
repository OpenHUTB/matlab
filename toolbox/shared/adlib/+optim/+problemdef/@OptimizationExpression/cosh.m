function eout=cosh(obj)







    Op=optim.internal.problemdef.operator.Cosh.getCoshOperator(obj);
    eout=createUnary(obj,Op);

end