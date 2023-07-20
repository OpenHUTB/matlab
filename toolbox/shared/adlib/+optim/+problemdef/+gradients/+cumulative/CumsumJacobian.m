function gradJacTrans=CumsumJacobian(opExpr,prodDim,direction)










    inputSize=size(opExpr);
    gradJacTrans=...
    optim.problemdef.gradients.cumulative.CumulativeStencil(inputSize,prodDim,direction,1);

end

