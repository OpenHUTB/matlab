function createNumeric(obj,Value)











    Node=optim.internal.problemdef.NumericExpressionImpl(Value);


    obj.Depth=1;


    obj.Stack={Node};

    Node.StackLength=1;


    obj.Type=optim.internal.problemdef.ImplType.Numeric;

end
