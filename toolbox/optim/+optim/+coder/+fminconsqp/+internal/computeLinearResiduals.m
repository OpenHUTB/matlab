function[workspaceIneq,workspaceEq]=...
    computeLinearResiduals(x,nVar,workspaceIneq,mLinIneq,AineqT,bineq,ldAi,workspaceEq,mLinEq,AeqT,beq,ldAe)






















%#codegen

    coder.allowpcode('plain');

    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});

    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(workspaceIneq,{'double'},{'2d'});
    validateattributes(mLinIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(AineqT,{'double'},{'2d'});
    validateattributes(bineq,{'double'},{'2d'});
    validateattributes(ldAe,{coder.internal.indexIntClass},{'scalar'});

    validateattributes(workspaceEq,{'double'},{'2d'});
    validateattributes(mLinEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(AeqT,{'double'},{'2d'});
    validateattributes(beq,{'double'},{'2d'});
    validateattributes(ldAe,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(nVar,mLinIneq,mLinEq,ldAi,ldAe);

    INT_ONE=coder.internal.indexInt(1);

    if(mLinIneq>0)

        workspaceIneq=coder.internal.blas.xcopy(mLinIneq,bineq,INT_ONE,INT_ONE,workspaceIneq,INT_ONE,INT_ONE);


        workspaceIneq=coder.internal.blas.xgemv('T',nVar,mLinIneq,1.0,AineqT,INT_ONE,ldAi,...
        x,INT_ONE,INT_ONE,-1.0,workspaceIneq,INT_ONE,INT_ONE);
    end

    if(mLinEq>0)

        workspaceEq=coder.internal.blas.xcopy(mLinEq,beq,INT_ONE,INT_ONE,workspaceEq,INT_ONE,INT_ONE);


        workspaceEq=coder.internal.blas.xgemv('T',nVar,mLinEq,1.0,AeqT,INT_ONE,ldAe,...
        x,INT_ONE,INT_ONE,-1.0,workspaceEq,INT_ONE,INT_ONE);
    end




end

