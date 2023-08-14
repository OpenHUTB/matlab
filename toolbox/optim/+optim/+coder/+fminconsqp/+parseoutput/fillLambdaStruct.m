function lambda=fillLambdaStruct(nVar,ScaleProblem,fscales,mLinIneq,mNonlinIneq,mLinEq,mNonlinEq,TrialState,WorkingSet,AeqDepIdx,nDepEq)

















%#codegen

    coder.allowpcode('plain');

    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ScaleProblem,{'logical'},{'scalar'});
    validateattributes(fscales,{'struct'},{'scalar'});
    validateattributes(mLinIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mNonlinIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mLinEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mNonlinEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(AeqDepIdx,{coder.internal.indexIntClass},{'2d'});
    validateattributes(nDepEq,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(nVar,ScaleProblem,fscales,mLinIneq,mNonlinIneq,mLinEq,mNonlinEq);

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));

    mFixed=WorkingSet.sizes(FIXED);
    mLB=WorkingSet.sizes(LOWER);
    mUB=WorkingSet.sizes(UPPER);

    lambda=struct();
    lambda.eqlin=zeros(mLinEq,1,'double');
    lambda.eqnonlin=zeros(mNonlinEq,1,'double');
    lambda.ineqlin=zeros(mLinIneq,1,'double');
    lambda.ineqnonlin=zeros(mNonlinIneq,1,'double');
    lambda.lower=zeros(nVar,1,'double');
    lambda.upper=zeros(nVar,1,'double');

    if ScaleProblem



        lambda_idx=1+mFixed;
        depIdx=coder.internal.indexInt(1);
        endIdx=mLinEq-nDepEq+1;
        for idx=1:mLinEq
            if(depIdx<=nDepEq&&AeqDepIdx(depIdx)==idx)
                lambda.eqlin(endIdx)=fscales.leq_constraint(idx)*TrialState.lambdaStopTest(lambda_idx)/fscales.objective;
                depIdx=depIdx+1;
                endIdx=endIdx+1;
            else
                lambda.eqlin(idx)=fscales.leq_constraint(idx)*TrialState.lambdaStopTest(lambda_idx)/fscales.objective;
            end
            lambda_idx=lambda_idx+1;
        end

        for idx=1:mNonlinEq
            lambda.eqnonlin(idx)=-fscales.ceq_constraint(idx)*TrialState.lambdaStopTest(lambda_idx)/fscales.objective;
            lambda_idx=lambda_idx+1;
        end

        for idx=1:mLinIneq
            lambda.ineqlin(idx)=fscales.lineq_constraint(idx)*TrialState.lambdaStopTest(lambda_idx)/fscales.objective;
            lambda_idx=lambda_idx+1;
        end

        for idx=1:mNonlinIneq
            lambda.ineqnonlin(idx)=fscales.cineq_constraint(idx)*TrialState.lambdaStopTest(lambda_idx)/fscales.objective;
            lambda_idx=lambda_idx+1;
        end

    else



        lambda_idx=1+mFixed;
        depIdx=coder.internal.indexInt(1);
        endIdx=mLinEq-nDepEq+1;
        for idx=1:(mLinEq-nDepEq)
            if(depIdx<=nDepEq&&AeqDepIdx(depIdx)==idx)
                lambda.eqlin(endIdx)=TrialState.lambdaStopTest(lambda_idx);
                depIdx=depIdx+1;
                endIdx=endIdx+1;
            else
                lambda.eqlin(idx)=TrialState.lambdaStopTest(lambda_idx);
            end
            lambda_idx=lambda_idx+1;
        end

        for idx=1:mNonlinEq
            lambda.eqnonlin(idx)=TrialState.lambdaStopTest(lambda_idx);
            lambda_idx=lambda_idx+1;
        end

        for idx=1:mLinIneq
            lambda.ineqlin(idx)=TrialState.lambdaStopTest(lambda_idx);
            lambda_idx=lambda_idx+1;
        end

        for idx=1:mNonlinIneq
            lambda.ineqnonlin(idx)=TrialState.lambdaStopTest(lambda_idx);
            lambda_idx=lambda_idx+1;
        end
    end


    for idx=1:mFixed
        idx_bnd=WorkingSet.indexFixed(idx);


        lambda.lower(idx_bnd)=-TrialState.lambdaStopTest(idx);
    end

    for idx=1:mLB
        idx_bnd=WorkingSet.indexLB(idx);
        lambda.lower(idx_bnd)=TrialState.lambdaStopTest(lambda_idx);
        lambda_idx=lambda_idx+1;
    end

    for idx=1:mUB
        idx_bnd=WorkingSet.indexUB(idx);
        lambda.upper(idx_bnd)=TrialState.lambdaStopTest(lambda_idx);
        lambda_idx=lambda_idx+1;
    end

end

