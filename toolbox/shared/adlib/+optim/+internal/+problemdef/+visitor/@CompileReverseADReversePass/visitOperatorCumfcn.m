function visitOperatorCumfcn(visitor,op,Node)







    leftVarName=getForwardMemory(visitor);


    jacStr=op.FileNameJacobian+createOperatorInputs(op,leftVarName);
    jacParens=1;


    PackageLocation="optim.problemdef.gradients.cumulative";


    pushAdjointString(visitor,jacStr,jacParens,Node,PackageLocation);

end
