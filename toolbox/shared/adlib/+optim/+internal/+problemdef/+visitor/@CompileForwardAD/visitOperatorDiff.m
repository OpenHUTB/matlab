function visitOperatorDiff(visitor,op,Node)






    leftVarName=declareChildArgumentName(visitor,1);


    visitOperatorDiff@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,op,Node);


    [jacStr,jacParens]=visitor.createDiffJacobianString(leftVarName,op.Order,op.Dim);


    PackageLocation="optim.problemdef.gradients.diff";


    pushTangentString(visitor,jacStr,jacParens,Node,PackageLocation);
end
