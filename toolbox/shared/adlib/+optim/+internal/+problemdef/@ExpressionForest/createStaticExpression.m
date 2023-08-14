function createStaticExpression(obj,lhsForest,stmtWrapper,type,vars)





















    tree=optim.internal.problemdef.ExpressionTree;


    lhsTree=forest2tree(lhsForest);


    createStaticExpression(tree,lhsTree,stmtWrapper,type,vars);


    tree2forest(obj,tree);
end
