function eout=log(obj)







    Op=optim.internal.problemdef.operator.Log.getLogOperator(obj);
    eout=createUnary(obj,Op);

end