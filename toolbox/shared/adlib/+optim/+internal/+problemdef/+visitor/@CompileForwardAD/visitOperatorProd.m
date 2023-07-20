function visitOperatorProd(visitor,op,Node)






    leftVarName=declareChildArgumentName(visitor,1);


    visitOperatorProd@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,op,Node);


    [jacStr,jacParens]=visitor.createProdJacobianString(Node.ExprLeft,leftVarName,op.Dimension);


    PackageLocation="optim.problemdef.gradients.prod";


    pushTangentString(visitor,jacStr,jacParens,Node,PackageLocation);

end
