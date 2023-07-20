function JacOut=DiagVectorInputTangent(opExpr,JacIn,diagK)











    N=numel(opExpr);


    dim=N+abs(diagK);


    idx=optim.problemdef.gradients.diag.DiagVectorInputIdx(opExpr,diagK);








    nVar=size(JacIn,1);
    Iidx=repelem((1:nVar)',1,N);



    Jidx=repelem(idx,1,nVar);


    JacOut=sparse(Iidx,Jidx,JacIn,nVar,dim^2);

end
