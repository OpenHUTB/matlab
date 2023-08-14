function LHSExprImpl=createLHSExpression(obj,lhsName)











    tree=optim.internal.problemdef.ExpressionTree;


    LHSExprImpl=createLHSExpression(tree,lhsName);


    tree2forest(obj,tree);

end
