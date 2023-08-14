function[cholmanager,qrmanager,memspace]=computeProjectedHessian_regularized(beta,H,nVarOrig,cholmanager,qrmanager,memspace)



































%#codegen

    coder.allowpcode('plain');


    validateattributes(beta,{'double'},{'scalar'});
    validateattributes(H,{'double'},{'2d'});
    validateattributes(nVarOrig,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(cholmanager,{'struct'},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});

    nVars=qrmanager.mrows;
    mConstr=qrmanager.ncols;
    mNull=coder.internal.indexInt(nVars-mConstr);

    ldw=coder.internal.indexInt(size(memspace.workspace_double,1));
    ldu=cholmanager.ldu;
    ldQ=qrmanager.ldq;
    ldH=nVarOrig;
    nullStart=coder.internal.indexInt(1+ldQ*mConstr);

    INT_ONE=coder.internal.indexInt(1);







    memspace.workspace_double=coder.internal.blas.xgemm('N','N',nVarOrig,mNull,nVarOrig,...
    1.0,H,INT_ONE,ldH,qrmanager.Q,nullStart,ldQ,0.0,memspace.workspace_double,INT_ONE,ldw);


    for idx_col=1:mNull
        for idx_row=nVarOrig+1:nVars
            memspace.workspace_double(idx_row,idx_col)=beta*qrmanager.Q(idx_row,idx_col+mConstr);
        end
    end


    cholmanager.UU=coder.internal.blas.xgemm('T','N',mNull,mNull,nVars,...
    1.0,qrmanager.Q,nullStart,ldQ,memspace.workspace_double,INT_ONE,ldw,0.0,cholmanager.UU,INT_ONE,ldu);

end
