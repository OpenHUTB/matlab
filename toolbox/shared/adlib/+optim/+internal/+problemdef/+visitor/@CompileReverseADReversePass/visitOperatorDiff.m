function visitOperatorDiff(visitor,op,Node)








    leftVarName=getForwardMemory(visitor);


    [jacStr,jacParens]=...
    optim.internal.problemdef.visitor.CompileForwardAD.createDiffJacobianString(...
    leftVarName,op.Order,op.Dim);


    PackageLocation="optim.problemdef.gradients.diff";


    pushAdjointString(visitor,jacStr,jacParens,Node,PackageLocation);
end
