function JacOut=DiagVectorInputAdjoint(opExpr,JacIn,diagK)










%#codegen
%#internal


    idx=optim.problemdef.gradients.diag.DiagVectorInputIdx(opExpr,diagK);


    JacOut=JacIn(idx,:);

end
