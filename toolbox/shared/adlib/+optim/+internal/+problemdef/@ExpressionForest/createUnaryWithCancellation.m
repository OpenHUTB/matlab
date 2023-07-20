function createUnaryWithCancellation(obj,Op,ExprLeft)










    if ExprLeft.SingleTreeSpansAllIndices

        copy(obj,ExprLeft);



        tree=optim.internal.problemdef.ExpressionTree;

        createUnaryWithCancellation(tree,Op,ExprLeft.TreeList{1});

        obj.TreeList{1}=tree;

        obj.Size=getOutputSize(Op,size(ExprLeft),[]);
    else

        createUnary(obj,Op,ExprLeft);
    end


end
