function[JacTrans_ip,constrGradNorms_ip]=formJacobian(xIndices,Aeq,Ain,JacCeqTrans,JacCineqTrans,...
    constrGradNormsSquared,slacks,sizes)











    mEq=sizes.mEq;
    mIneq=sizes.mIneq;
    nVar=sizes.nVar;
    nonlinEq_start=sizes.nonlinEq_start;
    ineq_start=sizes.ineq_start;
    nonlinIneq_start=sizes.nonlinIneq_start;



    sparseId=speye(nVar);

    JacTrans_ip=...
    [Aeq',sparseId(:,xIndices.fixed),JacCeqTrans,Ain',sparseId(:,xIndices.finiteLb),-sparseId(:,xIndices.finiteUb),JacCineqTrans
    sparse(mIneq,mEq),-spdiags(slacks,0,mIneq,mIneq)];










    constrGradNorms_ip=constrGradNormsSquared;
    constrGradNorms_ip(nonlinEq_start:ineq_start-1)=full(sum(JacCeqTrans.^2,1));
    constrGradNorms_ip(nonlinIneq_start:end)=full(sum(JacCineqTrans.^2,1));
    constrGradNorms_ip(ineq_start:end,1)=...
    constrGradNorms_ip(ineq_start:end,1)+slacks.^2;
    constrGradNorms_ip=sqrt(constrGradNorms_ip);
