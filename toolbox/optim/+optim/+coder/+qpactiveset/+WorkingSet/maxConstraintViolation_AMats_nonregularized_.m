function[v,obj]=maxConstraintViolation_AMats_nonregularized_(obj,x,ix0)












%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});

    validateattributes(ix0,{coder.internal.indexIntClass},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);

    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));

    v=0.0;

    mIneq=obj.sizes(AINEQ);
    mEq=obj.sizes(AEQ);



    if(~isempty(obj.Aineq))


        obj.maxConstrWorkspace=coder.internal.blas.xcopy(mIneq,obj.bineq,INT_ONE,INT_ONE,obj.maxConstrWorkspace,INT_ONE,INT_ONE);


        obj.maxConstrWorkspace=coder.internal.blas.xgemv('T',obj.nVar,mIneq,1.0,obj.Aineq,...
        INT_ONE,obj.ldA,x,ix0,INT_ONE,-1.0,obj.maxConstrWorkspace,INT_ONE,INT_ONE);

        for idx=1:mIneq
            v=max(v,obj.maxConstrWorkspace(idx));
        end
    end

    if(~isempty(obj.Aeq))

        obj.maxConstrWorkspace=coder.internal.blas.xcopy(mEq,obj.beq,INT_ONE,INT_ONE,obj.maxConstrWorkspace,INT_ONE,INT_ONE);


        obj.maxConstrWorkspace=coder.internal.blas.xgemv('T',obj.nVar,mEq,1.0,obj.Aeq,...
        INT_ONE,obj.ldA,x,ix0,INT_ONE,-1.0,obj.maxConstrWorkspace,INT_ONE,INT_ONE);

        for idx=1:mEq
            v=max(v,abs(obj.maxConstrWorkspace(idx)));
        end
    end

end