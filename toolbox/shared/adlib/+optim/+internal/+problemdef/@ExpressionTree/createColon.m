function createColon(obj,first,step,last)












    Node=optim.internal.problemdef.ColonExpressionImpl(first,step,last);


    obj.Depth=getDepth(Node);


    obj.Stack={Node};

    Node.StackLength=1;


    obj.Type=optim.internal.problemdef.ImplType.Numeric;

end
