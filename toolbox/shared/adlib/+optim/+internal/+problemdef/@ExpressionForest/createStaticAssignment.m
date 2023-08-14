function createStaticAssignment(obj,Op,ExprLeft,ExprRight,PtiesVisitor)


















    LeftTree=forest2tree(ExprLeft);
    RightTree=forest2tree(ExprRight);


    tree=optim.internal.problemdef.ExpressionTree;


    createStaticAssignment(tree,Op,LeftTree,RightTree,PtiesVisitor);


    tree2forest(obj,tree);


    ExprLeft.Size=tree.Size;
    ExprLeft.Variables=tree.Variables;

end
