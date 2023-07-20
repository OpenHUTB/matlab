function createUnary(obj,Op,ExprLeft)












    LeftTree=forest2tree(ExprLeft);


    tree=optim.internal.problemdef.ExpressionTree;


    createUnary(tree,Op,LeftTree);


    tree2forest(obj,tree);


end