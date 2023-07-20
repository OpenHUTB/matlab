function[scaledTangentialStep,numFunEvals,projCGIter,projCGIterRef,projCGStepType]=...
    tangentialStep(Hess,barrierHess_s,AugFactor,scaledNormalStep,scaledGrad_ip,slacks,...
    trRadius,bndryThresh,JacTrans_ip,funfcn,confcn,fscale,xCurrent,grad,lb,ub,xIndices,...
    lambda_ip,constrGradNorms_ip,options,sizes,varargin)











    nVar=sizes.nVar;nPrimal=sizes.nPrimal;
    trRadius_tang=sqrt(trRadius^2-scaledNormalStep'*scaledNormalStep);
    nonlinEq_start=sizes.nonlinEq_start;
    nonlinEq_end=sizes.nonlinEq_end;
    nonlinIneq_start=sizes.nonlinIneq_start;
    numFunEvals=0;





    [HessScaledNormalStep_x,evalCount]=hessTimesVector(Hess,scaledNormalStep(1:nVar),funfcn,confcn,xCurrent,...
    grad,JacTrans_ip(1:nVar,nonlinEq_start:nonlinEq_end),JacTrans_ip(1:nVar,nonlinIneq_start:end),...
    lb,ub,xIndices,fscale,lambda_ip,options,sizes,varargin{:});
    numFunEvals=numFunEvals+evalCount;
    initialResidual=[HessScaledNormalStep_x;barrierHess_s.*scaledNormalStep(nVar+1:nPrimal,1)]...
    +scaledGrad_ip;


    [scaledTangentialDir,scaledTangentialCauchyDir,evalCount,projCGIter,projCGIterRef,projCGStepType]=...
    projConjGrad(Hess,barrierHess_s,slacks,-initialResidual,AugFactor,trRadius_tang,...
    JacTrans_ip,options.TolProjCGAbs,options.TolProjCG,options.MaxProjCGIter,...
    funfcn,confcn,fscale,xCurrent,grad,lb,ub,xIndices,lambda_ip,constrGradNorms_ip,options,sizes,varargin{:});
    numFunEvals=numFunEvals+evalCount;



    [scaledTangentialStep,evalCount]=truncateTangStep(scaledTangentialDir,...
    scaledTangentialCauchyDir,projCGIter,scaledNormalStep,Hess,barrierHess_s,initialResidual,...
    bndryThresh,funfcn,confcn,xCurrent,grad,JacTrans_ip(1:nVar,nonlinEq_start:nonlinEq_end),...
    JacTrans_ip(1:nVar,nonlinIneq_start:end),lb,ub,xIndices,fscale,lambda_ip,options,sizes,varargin{:});
    numFunEvals=numFunEvals+evalCount;
