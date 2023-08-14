function JacOut=Diag2DMatrixInputTangent(opExpr,JacIn,diagK,Nout)











%#codegen
%#internal


    idx=optim.problemdef.gradients.diag.Diag2DMatrixInputIdx(opExpr,diagK,Nout);


    JacOut=JacIn(:,idx);

end
