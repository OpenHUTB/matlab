function createBinary(obj,Op,ExprLeft,ExprRight)














    LeftTree=forest2tree(ExprLeft);
    RightTree=forest2tree(ExprRight);


    tree=optim.internal.problemdef.ExpressionTree;


    createBinary(tree,Op,LeftTree,RightTree);


    tree2forest(obj,tree);

end