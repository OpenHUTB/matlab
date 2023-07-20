function[iss,newtree,c]=createExprIfSumSquares(tree)































    visitor=optim.internal.problemdef.visitor.CreateExprIfSumSquares;
    visitTree(visitor,tree);
    [iss,newStack,c]=getOutputs(visitor);

    if~iss

        c=0;
        newtree=[];
        return;
    end



    newtree=optim.internal.problemdef.ExpressionTree;


    newtree.Stack=newStack;



    newtree.Variables=tree.Variables;
    newtree.Type=computeType(tree.Type);





end



function type=computeType(inType)




    switch inType
    case optim.internal.problemdef.ImplType.Quadratic


        type=optim.internal.problemdef.ImplType.Linear;
    otherwise









        type=inType;
    end

end
