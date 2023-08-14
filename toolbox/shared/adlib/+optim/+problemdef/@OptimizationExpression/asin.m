function eout=asin(obj)







    Op=optim.internal.problemdef.operator.Asin.getAsinOperator(obj);
    eout=createUnary(obj,Op);

end