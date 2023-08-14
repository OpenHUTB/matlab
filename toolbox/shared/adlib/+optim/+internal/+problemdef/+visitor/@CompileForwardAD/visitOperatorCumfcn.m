function visitOperatorCumfcn(visitor,op,Node)






    leftVarName=declareChildArgumentName(visitor,1);


    visitOperatorCumfcn@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,op,Node);


    jacStr=op.FileNameJacobian+createOperatorInputs(op,leftVarName);
    jacParens=1;


    PackageLocation="optim.problemdef.gradients.cumulative";


    pushTangentString(visitor,jacStr,jacParens,Node,PackageLocation);

end
