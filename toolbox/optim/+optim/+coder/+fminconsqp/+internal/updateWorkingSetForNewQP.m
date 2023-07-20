function WorkingSet=updateWorkingSetForNewQP(xk,WorkingSet,...
    mIneq,mNonlinIneq,cIneq,...
    mEq,mNonlinEq,cEq,...
    mLB,lb,mUB,ub,mFixed)

































%#codegen

    coder.allowpcode('plain');






    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(mIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mNonlinIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(cIneq,{'double'},{'2d'});
    validateattributes(mEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mNonlinEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(cEq,{'double'},{'2d'});
    validateattributes(mLB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(mUB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ub,{'double'},{'2d'});
    validateattributes(mFixed,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(mIneq,mNonlinIneq,mEq,mNonlinEq,mFixed,mUB,mLB,lb,ub);

    nVar=WorkingSet.nVar;

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));


    for idx=1:mEq
        WorkingSet.beq(idx)=-cEq(idx);
        WorkingSet.bwset(mFixed+idx)=WorkingSet.beq(idx);
    end



    mLinEq=mEq-mNonlinEq;
    iw0=1+WorkingSet.ldA*(mFixed+mLinEq);
    iEq0=1+WorkingSet.ldA*(mLinEq);
    for idx=1:mNonlinEq



        for i=0:nVar-1
            WorkingSet.ATwset(iw0+i)=WorkingSet.Aeq(iEq0+i);
        end

        iw0=iw0+WorkingSet.ldA;
        iEq0=iEq0+WorkingSet.ldA;
    end


    for idx=1:mIneq
        WorkingSet.bineq(idx)=-cIneq(idx);
    end


    hasLB=~isempty(lb);
    hasUB=~isempty(ub);




    if hasLB
        for idx=1:mLB
            idx_finite=WorkingSet.indexLB(idx);


            WorkingSet.lb(idx_finite)=-lb(idx_finite)+xk(idx_finite);
        end
    end

    if hasUB
        for idx=1:mUB
            idx_finite=WorkingSet.indexUB(idx);


            WorkingSet.ub(idx_finite)=ub(idx_finite)-xk(idx_finite);
        end
    end

    if(hasLB&&hasUB)
        for idx=1:mFixed
            idx_finite=WorkingSet.indexFixed(idx);

            WorkingSet.ub(idx_finite)=ub(idx_finite)-xk(idx_finite);
            WorkingSet.bwset(idx)=ub(idx_finite)-xk(idx_finite);
        end
    end

    if(WorkingSet.nActiveConstr>mFixed+mEq)

        ineqStart=max(1,mFixed+mEq+1);
        for idx=ineqStart:WorkingSet.nActiveConstr
            idx_local=WorkingSet.Wlocalidx(idx);
            switch WorkingSet.Wid(idx)
            case LOWER
                idx_finite=WorkingSet.indexLB(idx_local);
                WorkingSet.bwset(idx)=WorkingSet.lb(idx_finite);
            case UPPER
                idx_finite=WorkingSet.indexUB(idx_local);
                WorkingSet.bwset(idx)=WorkingSet.ub(idx_finite);
            otherwise
                WorkingSet.bwset(idx)=WorkingSet.bineq(idx_local);
                if(mNonlinIneq>INT_ZERO&&idx_local>=mNonlinIneq)



                    iw0=1+WorkingSet.ldA*(idx-1);
                    ineq0=1+WorkingSet.ldA*(idx_local-1);
                    WorkingSet.ATwset=coder.internal.blas.xcopy(nVar,WorkingSet.Aineq,ineq0,INT_ONE,WorkingSet.ATwset,iw0,INT_ONE);
                end
            end
        end
    end

