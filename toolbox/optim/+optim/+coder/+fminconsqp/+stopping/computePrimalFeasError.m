function feasError=computePrimalFeasError(ScaleProblem,fscales,nVar,x,...
    mLinIneq,mNonlinIneq,cIneq,mLinEq,mNonlinEq,cEq,...
    finiteLB,mLB,lb,finiteUB,mUB,ub)












%#codegen

    coder.allowpcode('plain');


    validateattributes(ScaleProblem,{'logical'},{'scalar'});
    validateattributes(mLB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mLinIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mNonlinIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(cIneq,{'double'},{'2d'});
    validateattributes(mLinEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mNonlinEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(cEq,{'double'},{'2d'});
    validateattributes(finiteLB,{coder.internal.indexIntClass},{'2d'});
    validateattributes(mLB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(lb,{'double'},{'2d'});
    validateattributes(finiteUB,{coder.internal.indexIntClass},{'2d'});
    validateattributes(mUB,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ub,{'double'},{'2d'});

    coder.internal.prefer_const(ScaleProblem,fscales,nVar,mLinIneq,mNonlinIneq,mLinEq,mNonlinEq,finiteLB,mLB,lb,finiteUB,ub,mUB);

    feasError=0.0;
    mEq=mNonlinEq+mLinEq;
    mIneq=mNonlinIneq+mLinIneq;

    if ScaleProblem

        for idx=1:mLinEq
            curMax=abs(cEq(idx)/fscales.leq_constraint(idx));
            feasError=max(feasError,curMax);
        end
        for idx=1:mNonlinEq
            curMax=abs(cEq(mLinEq+idx)/fscales.ceq_constraint(idx));
            feasError=max(feasError,curMax);
        end


        for idx=1:mLinIneq
            curMax=cIneq(idx)/fscales.lineq_constraint(idx);
            feasError=max(feasError,curMax);
        end
        for idx=1:mNonlinIneq
            curMax=cIneq(mLinIneq+idx)/fscales.cineq_constraint(idx);
            feasError=max(feasError,curMax);
        end

    else

        for idx=1:mEq
            feasError=max(feasError,abs(cEq(idx)));
        end


        for idx=1:mIneq
            feasError=max(feasError,cIneq(idx));
        end
    end


    for idx=1:mLB
        idxFiniteLB=finiteLB(idx);
        feasError=max(feasError,lb(idxFiniteLB)-x(idxFiniteLB));
    end


    for idx=1:mUB
        idxFiniteUB=finiteUB(idx);
        feasError=max(feasError,x(idxFiniteUB)-ub(idxFiniteUB));
    end

end

