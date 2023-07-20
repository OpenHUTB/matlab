function createUnary(obj,Op,ExprLeft)












    Node=optim.internal.problemdef.UnaryExpressionImpl(Op,ExprLeft.Root);


    obj.Depth=ExprLeft.Depth+1;


    obj.Stack=[ExprLeft.Stack,{Node}];

    Node.StackLength=numel(obj.Stack);

    Node.ChildrenPosition=Node.StackLength-1;



    obj.Variables=ExprLeft.Variables;


    obj.Type=getOutputType(Op,ExprLeft.Type,[]);

end
