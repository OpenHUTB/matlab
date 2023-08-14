function workspace=...
    computeGradLag(workspace,ldA,nVar,...
    grad,mIneq,AineqTrans,mEq,AeqTrans,...
    finiteFixed,mFixed,finiteLB,mLB,finiteUB,mUB,lambda)


















%#codegen

    coder.allowpcode('plain');


    validateattributes(workspace,{'double'},{'2d'});
    validateattributes(ldA,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(grad,{'double'},{'2d'});
    validateattributes(mIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(AineqTrans,{'double'},{'2d'});
    validateattributes(mEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(AeqTrans,{'double'},{'2d'});
    validateattributes(finiteFixed,{coder.internal.indexIntClass},{'2d'});
    validateattributes(mFixed,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(finiteLB,{coder.internal.indexIntClass},{'2d'});
    validateattributes(mLB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(finiteUB,{coder.internal.indexIntClass},{'2d'});
    validateattributes(mUB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(lambda,{'double'},{'2d'});

    coder.internal.prefer_const(ldA,nVar);

    INT_ONE=coder.internal.indexInt(1);







    for i=1:nVar
        workspace(i)=grad(i);
    end


    for idx=1:mFixed
        idx_finiteFixed=finiteFixed(idx);
        workspace(idx_finiteFixed)=workspace(idx_finiteFixed)+lambda(idx);
    end


    iL0=mFixed+1;
    workspace=coder.internal.blas.xgemv('N',nVar,mEq,1.0,AeqTrans,INT_ONE,ldA,lambda,iL0,INT_ONE,1.0,workspace,INT_ONE,INT_ONE);


    iL0=iL0+mEq;
    workspace=coder.internal.blas.xgemv('N',nVar,mIneq,1.0,AineqTrans,INT_ONE,ldA,lambda,iL0,INT_ONE,1.0,workspace,INT_ONE,INT_ONE);


    iL0=iL0+mIneq;
    for idx=1:mLB
        idx_finiteLB=finiteLB(idx);
        workspace(idx_finiteLB)=workspace(idx_finiteLB)-lambda(iL0);
        iL0=iL0+1;
    end

    for idx=1:mUB
        idx_finiteUB=finiteUB(idx);
        workspace(idx_finiteUB)=workspace(idx_finiteUB)+lambda(iL0);
        iL0=iL0+1;
    end

end


