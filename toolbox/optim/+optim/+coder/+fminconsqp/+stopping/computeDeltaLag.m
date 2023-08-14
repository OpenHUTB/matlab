function workspace=computeDeltaLag(nVar,ldJ,mNonlinIneq,mNonlinEq,...
    workspace,grad,JacIneqTrans,ineqJ0,JacEqTrans,eqJ0,grad_old,JacIneqTrans_old,JacEqTrans_old,...
    lambda,ineqL0,eqL0)
































%#codegen

    coder.allowpcode('plain');


    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldJ,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mNonlinIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mNonlinEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(workspace,{'double'},{'2d'});
    validateattributes(grad,{'double'},{'2d'});
    validateattributes(JacIneqTrans,{'double'},{'2d'});
    validateattributes(ineqJ0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(JacEqTrans,{'double'},{'2d'});
    validateattributes(eqJ0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(grad_old,{'double'},{'2d'});
    validateattributes(JacIneqTrans_old,{'double'},{'2d'});
    validateattributes(JacEqTrans_old,{'double'},{'2d'});
    validateattributes(lambda,{'double'},{'2d'});
    validateattributes(ineqL0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(eqL0,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(nVar,ldJ,mNonlinIneq,mNonlinEq,ineqL0,eqL0);

    INT_ONE=coder.internal.indexInt(1);







    for i=1:nVar
        workspace(i)=grad(i);
    end


    workspace=coder.internal.blas.xaxpy(nVar,-1.0,grad_old,INT_ONE,INT_ONE,workspace,INT_ONE,INT_ONE);

    if(mNonlinEq>0)


        eqJ0=1+ldJ*(eqJ0-1);
        workspace=coder.internal.blas.xgemv('N',nVar,mNonlinEq,1.0,JacEqTrans,eqJ0,ldJ,lambda,eqL0,INT_ONE,1.0,workspace,INT_ONE,INT_ONE);


        workspace=coder.internal.blas.xgemv('N',nVar,mNonlinEq,-1.0,JacEqTrans_old,INT_ONE,ldJ,lambda,eqL0,INT_ONE,1.0,workspace,INT_ONE,INT_ONE);

    end

    if(mNonlinIneq>0)

        ineqJ0=1+ldJ*(ineqJ0-1);
        workspace=coder.internal.blas.xgemv('N',nVar,mNonlinIneq,1.0,JacIneqTrans,ineqJ0,ldJ,lambda,ineqL0,INT_ONE,1.0,workspace,INT_ONE,INT_ONE);


        workspace=coder.internal.blas.xgemv('N',nVar,mNonlinIneq,-1.0,JacIneqTrans_old,INT_ONE,ldJ,lambda,ineqL0,INT_ONE,1.0,workspace,INT_ONE,INT_ONE);
    end

end


