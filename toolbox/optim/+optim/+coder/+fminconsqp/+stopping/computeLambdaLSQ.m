function[lambdaLSQ,QRManager,workspace]=...
    computeLambdaLSQ(nVar,mConstr,QRManager,ATwset,ldA,grad,lambdaLSQ,iL0,workspace,iw0)













%#codegen

    coder.allowpcode('plain');


    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mConstr,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(QRManager,{'struct'},{'scalar'});
    validateattributes(ATwset,{'double'},{'2d'});
    validateattributes(ldA,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(grad,{'double'},{'vector'});
    validateattributes(lambdaLSQ,{'double'},{'2d'});
    validateattributes(iL0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(workspace,{'double'},{'2d'});
    validateattributes(iw0,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(nVar,mConstr);

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);


    lambdaLSQ=coder.internal.blas.xcopy(mConstr,0.0,INT_ONE,INT_ZERO,lambdaLSQ,iL0,INT_ONE);

    QRManager=optim.coder.QRManager.factorQRE(QRManager,ATwset,nVar,mConstr,ldA);
    QRManager=optim.coder.QRManager.computeSquareQ(QRManager);


    workspace=coder.internal.blas.xgemv('T',nVar,nVar,1.0,QRManager.Q,INT_ONE,QRManager.ldq,...
    grad,INT_ONE,INT_ONE,...
    0.0,workspace,iw0,INT_ONE);


    scaleTol=double(max(nVar,mConstr))*eps('double');
    scaleTol=min(sqrt(eps('double')),scaleTol);
    tol=abs(QRManager.QR(INT_ONE))*scaleTol;
    fullRank_R=min(nVar,mConstr);
    rankR=coder.internal.indexInt(0);
    iQR_diag=INT_ONE;
    while(rankR<fullRank_R&&abs(QRManager.QR(iQR_diag))>tol)
        rankR=rankR+1;
        iQR_diag=iQR_diag+QRManager.ldq+1;
    end



    workspace=coder.internal.blas.xtrsv('U','N','N',...
    rankR,QRManager.QR,INT_ONE,QRManager.ldq,workspace,iw0,INT_ONE);






    minDim=min(mConstr,fullRank_R);
    iL0=iL0-1;
    for idx=1:minDim
        pivotIdx=QRManager.jpvt(idx);
        lambdaLSQ(iL0+pivotIdx)=workspace(idx);
    end

end

