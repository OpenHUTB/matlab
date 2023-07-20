function createBinary(obj,Op,ExprLeft,ExprRight)













    Node=optim.internal.problemdef.BinaryExpressionImpl(Op,ExprLeft.Root,ExprRight.Root);


    obj.Depth=max(ExprLeft.Depth,ExprRight.Depth)+1;











    if strcmp(ExprRight.Root.Id,ExprLeft.Root.Id)
        vars=ExprRight.Variables;
        stack=[ExprRight.Stack,{Node}];
        nNodes=numel(stack)-1;
        Node.ChildrenPosition=[nNodes,nNodes];
    else


        vars=...
        optim.internal.problemdef.HashMapFunctions.union(...
        ExprLeft.Variables,ExprRight.Variables,'OptimizationExpression');





        ShouldReverse=(ExprLeft.Depth<ExprRight.Depth);



        if ShouldReverse
            stack=[ExprRight.Stack,ExprLeft.Stack,{Node}];
            nNodesRight=numel(ExprRight.Stack);
            Node.ChildrenPosition=[numel(ExprLeft.Stack)+nNodesRight,nNodesRight];
        else
            stack=[ExprLeft.Stack,ExprRight.Stack,{Node}];
            nNodesLeft=numel(ExprLeft.Stack);
            Node.ChildrenPosition=[nNodesLeft,numel(ExprRight.Stack)+nNodesLeft];
        end
    end

    Node.StackLength=numel(stack);


    obj.Variables=vars;


    obj.Stack=stack;


    obj.Type=getOutputType(Op,ExprLeft.Type,ExprRight.Type);

end
