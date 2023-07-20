function createEndIndex(obj)









    Node=optim.internal.problemdef.EndIndexExpressionImpl.getEndIndex();


    obj.Depth=1;


    obj.Stack={Node};

    Node.StackLength=1;


    obj.Type=optim.internal.problemdef.ImplType.Numeric;

end
