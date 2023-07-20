function lambda=formLambdaStruct(lambdaStopTest,grad,xIndices,sizes,separateBounds)














    lambda.eqlin=lambdaStopTest(1:sizes.mLinEq,1);
    lambda.eqnonlin=lambdaStopTest(sizes.nonlinEq_start:sizes.nonlinEq_end,1);
    lambda.ineqlin=lambdaStopTest(sizes.mEq+1:sizes.mEq+sizes.mLinIneq,1);


    lambda.lower=zeros(sizes.nVar,1);
    lambda.upper=zeros(sizes.nVar,1);

    if separateBounds
        lambda.ineqnonlin=lambdaStopTest(sizes.nonlinIneq_start:sizes.finiteLb_start-1,1);

        lambda_finiteLb=...
        lambdaStopTest(sizes.finiteLb_start:sizes.finiteUb_start-1,1);
        lambda_finiteUb=...
        lambdaStopTest(sizes.finiteUb_start:end,1);
    else
        lambda.ineqnonlin=lambdaStopTest(sizes.nonlinIneq_start:end,1);

        lambda_finiteLb=...
        lambdaStopTest(sizes.mEq+sizes.mLinIneq+1:sizes.mEq+sizes.mLinIneq+sizes.nFiniteLb,1);
        lambda_finiteUb=...
        lambdaStopTest(sizes.mEq+sizes.mLinIneq+sizes.nFiniteLb+1:...
        sizes.mEq+sizes.mLinIneq+sizes.nFiniteLb+sizes.nFiniteUb,1);








        lambda_fixed_vars=zeros(sizes.nVar,1);


        lambda_fixed_vars(xIndices.fixed)=...
        lambdaStopTest(sizes.mLinEq+1:sizes.mLinEq+sizes.nFixedVar,1);
        active_index=(xIndices.fixed)&(grad>=0);
        lambda.lower(active_index)=lambda_fixed_vars(active_index);
        active_index=xIndices.fixed&(grad<0);
        lambda.upper(active_index)=-lambda_fixed_vars(active_index);
    end

    lambda.lower(xIndices.finiteLb)=lambda_finiteLb;
    lambda.upper(xIndices.finiteUb)=lambda_finiteUb;


    lambda.eqlin=-lambda.eqlin;
    lambda.eqnonlin=-lambda.eqnonlin;
