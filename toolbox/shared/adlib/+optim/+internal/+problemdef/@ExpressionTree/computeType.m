function type=computeType(tree)






    visitor=optim.internal.problemdef.visitor.ComputeType;
    visitTree(visitor,tree);
    type=getOutputs(visitor);

end