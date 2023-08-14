function[lambda_ip,lambdaBarrierStopTest]=leastSquaresLagrangeMults(...
    AugFactor,grad,slacks,barrierParam,computeBarrierMults,sizes)













    mEq=sizes.mEq;mIneq=sizes.mIneq;

    if computeBarrierMults


        rhs2=-barrierParam*ones(mIneq,1);
    else


        rhs2=zeros(mIneq,1);
    end
    [~,lambda_ip]=solveAugSystem(AugFactor,...
    grad,rhs2,zeros(mEq,1),zeros(mIneq,1),...
    slacks,sizes);


    z=lambda_ip(mEq+1:end,1);
    if computeBarrierMults





        lambdaBarrierStopTest=lambda_ip;
        lambdaBarrierStopTest(mEq+1:end,1)=max(0.0,z);
        zTooSmall_idx=(z<=1e-15);
        z(zTooSmall_idx)=barrierParam./slacks(zTooSmall_idx);
    else
        lambdaBarrierStopTest=[];
        z=max(0.0,z);
    end
    lambda_ip(mEq+1:end,1)=z;

