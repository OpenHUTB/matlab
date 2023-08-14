function[cholmanager,qrmanager,memspace]=computeProjectedHessian(H,cholmanager,qrmanager,memspace)

































%#codegen

    coder.allowpcode('plain');


    validateattributes(H,{'double'},{'2d'});
    validateattributes(cholmanager,{'struct'},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});

    nVars=qrmanager.mrows;
    mConstr=qrmanager.ncols;
    mNull=coder.internal.indexInt(nVars-mConstr);

    ldw=coder.internal.indexInt(size(memspace.workspace_double,1));
    ldm=cholmanager.ldm;
    ldQ=qrmanager.ldq;
    ldH=nVars;
    nullStart=coder.internal.indexInt(1+ldQ*mConstr);

    INT_ONE=coder.internal.indexInt(1);



    memspace.workspace_double=coder.internal.blas.xgemm('N','N',nVars,mNull,nVars,...
    1.0,H,INT_ONE,ldH,qrmanager.Q,nullStart,ldQ,0.0,memspace.workspace_double,INT_ONE,ldw);


    cholmanager.FMat=coder.internal.blas.xgemm('T','N',mNull,mNull,nVars,...
    1.0,qrmanager.Q,nullStart,ldQ,memspace.workspace_double,INT_ONE,ldw,0.0,cholmanager.FMat,INT_ONE,ldm);

end
