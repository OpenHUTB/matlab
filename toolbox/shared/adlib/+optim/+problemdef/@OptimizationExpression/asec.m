function eout=asec(obj)







    Op=optim.internal.problemdef.operator.Asec.getAsecOperator(obj);
    eout=createUnary(obj,Op);

end