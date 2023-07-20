function[penaltyParamTrial,modelDecrease,numFunEvals]=updatePenaltyParam(penaltyParam,penaltyParamMin,...
    step,c_pred,scaledGrad_ip,Hess,barrierHess_s,barrIter,funfcn,confcn,xCurrent,...
    grad,JacCeqTrans,JacCineqTrans,lb,ub,xIndices,fscale,lambda_ip,options,sizes,useDirect,varargin)












    numFunEvals=0;

    if~isempty(Hess)

        [HessStep_x,evalCount]=hessTimesVector(Hess,step(1:sizes.nVar),funfcn,confcn,xCurrent,...
        grad,JacCeqTrans,JacCineqTrans,lb,ub,xIndices,fscale,lambda_ip,options,sizes,varargin{:});
        numFunEvals=numFunEvals+evalCount;



        Hess_ip_step=[HessStep_x;barrierHess_s.*step(sizes.nVar+1:sizes.nPrimal,1)];
        step_Hess_ip_step=step'*Hess_ip_step;
    end


    if isempty(Hess)||useDirect&&step_Hess_ip_step<0
        obj_pred=-scaledGrad_ip'*step;
    else
        obj_pred=(-scaledGrad_ip'*step)-0.5*step_Hess_ip_step;
    end


    if sizes.mAll==0

        penaltyParamTrial=0;
        modelDecrease=obj_pred;
    elseif c_pred<=0

        penaltyParamTrial=penaltyParam;
        modelDecrease=obj_pred;
    else
        penaltyParamTrial=-1.5*obj_pred/c_pred;
        if barrIter==0&&useDirect

            penaltyParamTrial=max(penaltyParamMin,penaltyParamTrial);
        else

            penaltyParamTrial=max(penaltyParam,penaltyParamTrial);
        end
        modelDecrease=obj_pred+penaltyParamTrial*c_pred;
    end


