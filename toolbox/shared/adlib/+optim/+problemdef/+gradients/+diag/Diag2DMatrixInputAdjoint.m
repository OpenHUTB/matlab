function JacOut=Diag2DMatrixInputAdjoint(opExpr,JacIn,diagK,Nout)












    N=numel(opExpr);


    idx=optim.problemdef.gradients.diag.Diag2DMatrixInputIdx(opExpr,diagK,Nout);








    nVar=size(JacIn,2);
    Jidx=repelem((1:nVar),1,Nout);



    Iidx=repelem(idx',1,nVar);


    JacOut=sparse(Iidx,Jidx,JacIn,N,nVar);

end
