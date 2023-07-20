function[lhs,rhs,dx]=linearLeastSquares(lhs,rhs,dx,m,n)


















%#codegen

    coder.allowpcode('plain');
    coder.internal.prefer_const(lhs,rhs,dx,m,n);

    validateattributes(lhs,{'double'},{'size',[m,n]});
    validateattributes(rhs,{'double'},{'size',[m,1]});
    validateattributes(dx,{'double'},{'numel',n});
    validateattributes(m,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(n,{coder.internal.indexIntClass},{'scalar'});


    jpvt=zeros(n,1);
    ia0=1;
    [lhs,tau,jpvt]=coder.internal.lapack.xgeqp3(lhs,ia0,m,n,jpvt);


    rhs=coder.internal.lapack.xunormqr(lhs,rhs,tau);


    uplo='U';
    transa='N';
    diaga='N';
    ia0=1;
    lda=m;
    ix0=1;
    incx=1;
    dx(:)=coder.internal.blas.xtrsv(uplo,transa,diaga,n,lhs,ia0,lda,rhs(1:n),ix0,incx);
    dx(jpvt)=dx;

end