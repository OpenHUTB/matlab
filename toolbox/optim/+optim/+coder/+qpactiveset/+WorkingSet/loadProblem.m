function obj=loadProblem(obj,mIneq,mLinIneq,Aineq,bineq,...
    mEq,mLinEq,Aeq,beq,...
    mLB,lb,...
    mUB,ub,...
    mFixed,mConstrMax)














%#codegen

    coder.allowpcode('plain');




    validateattributes(mIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mLinIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(Aineq,{'double'},{'2d'});
    validateattributes(bineq,{'double'},{'2d'});
    validateattributes(mEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mLinEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(Aeq,{'double'},{'2d'});
    validateattributes(beq,{'double'},{'2d'});
    validateattributes(mLB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(mUB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ub,{'double'},{'2d'});
    validateattributes(mFixed,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mConstrMax,{coder.internal.indexIntClass},{'scalar'});






    coder.internal.prefer_const(mIneq,mLinIneq,Aineq,bineq,...
    mEq,mLinEq,Aeq,beq,...
    mLB,lb,...
    mUB,ub,...
    mFixed,mConstrMax);





    obj.mConstr(:)=coder.internal.indexInt(mIneq+mEq+mLB+mUB+mFixed);
    obj.mConstrOrig(:)=coder.internal.indexInt(mIneq+mEq+mLB+mUB+mFixed);
    obj.mConstrMax(:)=coder.internal.indexInt(mConstrMax);





    obj.sizes(:)=[mFixed;mEq;mIneq;mLB;mUB];
    obj.sizesNormal(:)=[mFixed;mEq;mIneq;mLB;mUB];
    obj.sizesPhaseOne(:)=[mFixed;mEq;mIneq;mLB+1;mUB];
    obj.sizesRegularized(:)=[mFixed;mEq;mIneq;mLB+mIneq+2*mEq;mUB];
    obj.sizesRegPhaseOne(:)=[mFixed;mEq;mIneq;mLB+mIneq+2*mEq+1;mUB];








    obj.isActiveIdx(:)=coder.internal.indexInt(cumsum([1;mFixed;mEq;mIneq;mLB;mUB]));
    obj.isActiveIdxNormal(:)=coder.internal.indexInt(cumsum([1;mFixed;mEq;mIneq;mLB;mUB]));
    obj.isActiveIdxPhaseOne(:)=coder.internal.indexInt(cumsum([1;mFixed;mEq;mIneq;mLB+1;mUB]));
    obj.isActiveIdxRegularized(:)=coder.internal.indexInt(cumsum([1;mFixed;mEq;mIneq;mLB+mIneq+2*mEq;mUB]));
    obj.isActiveIdxRegPhaseOne(:)=coder.internal.indexInt(cumsum([1;mFixed;mEq;mIneq;mLB+mIneq+2*mEq+1;mUB]));



    INT_ONE=coder.internal.indexInt(1);





    if(mIneq>0)


        for idx_col=1:mLinIneq
            for idx_row=1:obj.nVar
                idxPosCache=idx_row+obj.ldA*(idx_col-INT_ONE);
                idxPosAineq=idx_col+mLinIneq*(idx_row-INT_ONE);
                obj.Aineq(idxPosCache)=Aineq(idxPosAineq);
            end
        end
        if~isempty(bineq)
            obj.bineq=coder.internal.blas.xcopy(mLinIneq,bineq,INT_ONE,INT_ONE,obj.bineq,INT_ONE,INT_ONE);
        end
    end

    if(mEq>0)


        for idx_col=1:mLinEq
            for idx_row=1:obj.nVar
                idxPosCache=idx_row+obj.ldA*(idx_col-INT_ONE);
                idxPosAineq=idx_col+mLinEq*(idx_row-INT_ONE);
                obj.Aeq(idxPosCache)=Aeq(idxPosAineq);
            end
        end
        if~isempty(beq)
            obj.beq=coder.internal.blas.xcopy(mLinEq,beq,INT_ONE,INT_ONE,obj.beq,INT_ONE,INT_ONE);
        end
    end



    if~isempty(lb)
        for idx=1:obj.nVar
            obj.lb(idx)=-lb(idx);
        end
    end
    if~isempty(ub)
        obj.ub=coder.internal.blas.xcopy(obj.nVar,ub,INT_ONE,INT_ONE,obj.ub,INT_ONE,INT_ONE);
    end

end

