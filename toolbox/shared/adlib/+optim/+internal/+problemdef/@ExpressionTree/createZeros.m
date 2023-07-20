function createZeros(obj,sz)











    Node=optim.internal.problemdef.ZeroExpressionImpl(sz);


    obj.Depth=1;


    obj.Stack={Node};

    Node.StackLength=1;


    obj.Type=optim.internal.problemdef.ImplType.Numeric;

end
