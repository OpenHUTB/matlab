function eout=createStaticSubsref(ExprLeft,index)











    Op=optim.internal.problemdef.operator.StaticSubsref(ExprLeft,index);
    eout=createUnary(ExprLeft,Op);


