function Hessian=BFGSReset(Hessian,grad,searchDir)






















%#codegen

    coder.allowpcode('plain');


    validateattributes(Hessian,{'double'},{'2d','nonempty'});
    validateattributes(grad,{'double'},{'vector'});
    validateattributes(searchDir,{'double'},{'vector'});

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);
    nVar=coder.internal.indexInt(size(Hessian,1));



    nrmGradInf=0.0;
    nrmDirInf=1.0;
    for idx=1:nVar
        nrmGradInf=max(nrmGradInf,abs(grad(idx)));
        nrmDirInf=max(nrmDirInf,abs(searchDir(idx)));
    end
    diagVal=max(eps('double'),nrmGradInf/nrmDirInf);



    for idx_col=1:nVar
        iH0=1+nVar*(idx_col-1);
        Hessian=coder.internal.blas.xcopy(idx_col-1,0.0,INT_ONE,INT_ZERO,Hessian,iH0,INT_ONE);

        Hessian(idx_col,idx_col)=diagVal;

        iH0=iH0+idx_col;
        Hessian=coder.internal.blas.xcopy(nVar-idx_col,0.0,INT_ONE,INT_ZERO,Hessian,iH0,INT_ONE);
    end


end

