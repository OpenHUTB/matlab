function[trialStep,c_pred,KKTfactor,CompactAugMatrix,AugFactor,augFactorsUpToDate,...
    funcCount,innerIter_prnt,legend_prnt,barrierParam,stateFeas]=...
    computeTrialStep(trialStep,Hess,barrierHess_s,JacTrans_ip,...
    scaledGrad_ip,lambda_ip,c_ip,lambdaTrial_ip,cTrial_ip,xCurrent,lb,ub,...
    xIndices,grad,JacCeqTrans,JacCineqTrans,fscale,constrGradNorms_ip,...
    c_pred,KKT_error,KKTfactor,CompactAugMatrix,AugFactor,augFactorsUpToDate,...
    slacks,barrierParam,trRadius,funcCount,honorBndsOnlyMode,honorIneqsBndsMode,...
    constants,options,sizes,funfcn,confcn,iter,...
    stateFeas,nlpPrimalFeasError,varargin)

































    bndryThresh=constants.bndryThresh;
    mAll=sizes.mAll;
    nVar=sizes.nVar;
    mEq=sizes.mEq;
    mIneq=sizes.mIneq;
    nPrimal=sizes.nPrimal;

    if~strcmpi(trialStep.type,'cg')
        stateFeas.switchViolations=0;
    end

    trialStep.autoReject=false;
    switch trialStep.type
    case{'direct','pc','cg','cgfeas'}



        if strcmpi(trialStep.type,'direct')||strcmpi(trialStep.type,'pc')




            if strcmpi(options.BarrierParamUpdate,'monotone')||strcmpi(trialStep.type,'pc')
                KKTfactor=formAndFactorKKTmatrix(KKTfactor,Hess,barrierHess_s,JacTrans_ip,...
                KKT_error,barrierParam,options,sizes);
            end
            if KKTfactor.numNegEig>mAll
                trialStep.useDirect=false;
                trialStep.type='cg';

                if strcmpi(options.BarrierParamUpdate,'predictor-corrector')


                    barrierParam=barrierAdaptiveUpdate(lambda_ip,slacks,sizes,options);
                end
            else

                if strcmpi(trialStep.type,'pc')
                    kktAffineRhs=-[[grad;zeros(mIneq,1)]-JacTrans_ip*lambda_ip;c_ip];
                    kktAffineSol=solveKKTsystem(KKTfactor,Hess,kktAffineRhs,sizes,options);
                    dsAff=kktAffineSol(nVar+1:nVar+mIneq,1);
                    dzAff=kktAffineSol(nPrimal+mEq+1:end,1);
                    alpha_s_Aff=fractionToBoundaryScaled(dsAff,bndryThresh);
                    z=lambda_ip(mEq+1:end,1);
                    alpha_z_Aff=fractionToBoundary(z,dzAff,bndryThresh);
                    mu_Aff=dot(slacks+alpha_s_Aff*slacks.*dsAff,...
                    z+alpha_z_Aff*dzAff)/mIneq;
                    mu=dot(slacks,z)/mIneq;
                    sigma=max(options.SigmaFloor,(mu_Aff/mu)^3);
                    barrierParam=mu*sigma;
                    kktRhs=-[grad-JacTrans_ip(1:nVar,:)*lambda_ip;...
                    -mu*sigma+slacks.*dsAff.*dzAff+slacks.*z;...
                    c_ip];
                else
                    kktRhs=-[scaledGrad_ip-JacTrans_ip*lambda_ip;c_ip];
                end
                trialStep.direct=solveKKTsystem(KKTfactor,Hess,kktRhs,sizes,options);

                trialStep.alpha_s=fractionToBoundaryScaled(trialStep.direct(nVar+1:nVar+mIneq,1),bndryThresh);
                trialStep.alpha_z=fractionToBoundary(lambda_ip(mEq+1:end,1),trialStep.direct(nPrimal+mEq+1:end,1),bndryThresh);

                if strcmpi(options.AlwaysHonorConstraints,'bounds')||strcmpi(options.AlwaysHonorConstraints,'bounds-ineqs')
                    alpha_x=fractionToBoundaryHonorBounds(xCurrent,lb,ub,xIndices,...
                    trialStep.direct(1:nVar),bndryThresh);
                    trialStep.alpha_s=min(trialStep.alpha_s,alpha_x);
                end

                if min(trialStep.alpha_s,trialStep.alpha_z)<1e-5
                    trialStep.useDirect=false;

                    trialStep.type='cg';
                    if strcmpi(options.BarrierParamUpdate,'predictor-corrector')


                        barrierParam=barrierAdaptiveUpdate(lambda_ip,slacks,sizes,options);
                    end
                else


                    trialStep.useDirect=true;
                    trialStep.primal=trialStep.alpha_s*trialStep.direct(1:nPrimal,1);
                    trialStep.dual=trialStep.alpha_z*trialStep.direct(nPrimal+1:end,1);

                    c_pred=trialStep.alpha_s*norm(c_ip);
                    innerIter_prnt=[0,0];legend_prnt='';
                end
            end
        end
        if strcmpi(trialStep.type,'cg')||strcmpi(trialStep.type,'cgfeas')

            trialStep.useDirect=false;
            if~augFactorsUpToDate
                [CompactAugMatrix,AugFactor]=formAndFactorAugMatrix(CompactAugMatrix,AugFactor,...
                JacTrans_ip,slacks,KKT_error,barrierParam,sizes,options);
                augFactorsUpToDate=true;
            end

            if strcmpi(trialStep.type,'cg')
                [trialStep.normal,c_pred]=normalStep(c_ip,JacTrans_ip,trRadius,...
                AugFactor,slacks,bndryThresh,honorBndsOnlyMode,honorIneqsBndsMode,...
                sizes);
            end


            if strcmpi(options.EnableFeasibilityMode,'always')
                trialStep.type='cgfeas';
            elseif options.EnableFeasibilityMode&&strcmpi(trialStep.type,'cg')

                [trialStep.type,stateFeas.switchViolations]=checkFeasibilityMode(trialStep,c_ip,...
                JacTrans_ip,iter,stateFeas.latestPrimalFeasError,stateFeas.switchViolations,sizes,options);
            elseif strcmpi(trialStep.type,'cgfeas')

                if nlpPrimalFeasError<(1-options.SufInfeasDecrease)*stateFeas.latestPrimalFeasError(end)
                    trialStep.type='cg';
                    stateFeas.enabled=false;
                    stateFeas.switchViolations=0;


                    [trialStep.normal,c_pred]=normalStep(c_ip,JacTrans_ip,trRadius,...
                    AugFactor,slacks,bndryThresh,honorBndsOnlyMode,honorIneqsBndsMode,...
                    sizes);
                end
            end

            if strcmpi(trialStep.type,'cgfeas')
                cEq=c_ip(1:mEq);

                cIneq=c_ip(mEq+1:end)+slacks;
                [trialStep,stateFeas]=feasibilityStep(stateFeas,xCurrent,...
                cEq,cIneq,JacTrans_ip,barrierParam,slacks,...
                trRadius,bndryThresh,sizes,options);
                numFunEvals=0;
                projCGIter=0;
                projCGIterRef=0;
                projCGStepType='projgrad';
                trialStep.useDirect=false;
            else
                [trialStep.tangential,numFunEvals,projCGIter,projCGIterRef,projCGStepType]=...
                tangentialStep(Hess,barrierHess_s,AugFactor,trialStep.normal,scaledGrad_ip,...
                slacks,trRadius,bndryThresh,JacTrans_ip,funfcn,confcn,fscale,xCurrent,grad,...
                lb,ub,xIndices,lambda_ip,constrGradNorms_ip,options,sizes,varargin{:});
                trialStep.alpha_s=1;trialStep.alpha_z=1;

            end
            trialStep.primal=trialStep.normal+trialStep.tangential;
            trialStep.dual=[];
            trialStep.projCGIter=trialStep.projCGIter+projCGIter;
            funcCount=funcCount+numFunEvals;
            innerIter_prnt=[projCGIter,projCGIterRef];legend_prnt=projCGStepType;
        end
    case 'directsoc'

        trialStep.useDirect=true;

        Hess_ip_step=[hessTimesVector(Hess,trialStep.primal(1:nVar),funfcn,confcn,xCurrent,...
        grad,JacCeqTrans,JacCineqTrans,lb,ub,xIndices,fscale,lambda_ip,options,sizes,varargin{:});
        barrierHess_s.*trialStep.primal(nVar+1:nPrimal,1)];
        socRhs=-[scaledGrad_ip+Hess_ip_step-JacTrans_ip*lambdaTrial_ip;cTrial_ip];
        directSocStep=solveKKTsystem(KKTfactor,Hess,socRhs,sizes,options);


        if norm(directSocStep(1:nPrimal,1))>2*norm(trialStep.primal)
            trialStep.autoReject=true;
        else

            alphaSOC_s=fractionToBoundaryScaled(trialStep.primal(nVar+1:nPrimal,1)+directSocStep(nVar+1:nPrimal,1),bndryThresh);
            alphaSOC_z=fractionToBoundary(lambda_ip(mEq+1:end,1),...
            trialStep.dual(mEq+1:end,1)+directSocStep(nPrimal+mEq+1:end,1),bndryThresh);

            if strcmpi(options.AlwaysHonorConstraints,'bounds')||strcmpi(options.AlwaysHonorConstraints,'bounds-ineqs')
                alphaSOC_x=fractionToBoundaryHonorBounds(xCurrent,lb,ub,xIndices,...
                trialStep.primal(1:nVar)+directSocStep(1:nVar),bndryThresh);
                alphaSOC_s=min(alphaSOC_s,alphaSOC_x);
            end

            trialStep.primal=alphaSOC_s*(trialStep.primal+directSocStep(1:nPrimal,1));
            trialStep.dual=alphaSOC_z*(trialStep.dual+directSocStep(nPrimal+1:end,1));
        end
        innerIter_prnt=[0,0];legend_prnt='';
    case 'cgsoc'

        trialStep.useDirect=false;
        cgSocStep=solveAugSystem(AugFactor,...
        zeros(nVar,1),zeros(mIneq,1),cTrial_ip(1:mEq,1),cTrial_ip(mEq+1:mAll,1),...
        slacks,sizes);

        cgSocStep=-cgSocStep;


        if norm(cgSocStep)>2*norm(trialStep.primal)
            trialStep.autoReject=true;
        else

            alphaSOC_s=fractionToBoundaryScaled(trialStep.primal(nVar+1:nPrimal,1)+cgSocStep(nVar+1:nPrimal,1),bndryThresh);
            trialStep.primal=alphaSOC_s*(trialStep.primal+cgSocStep);
        end
        innerIter_prnt=[0,0];legend_prnt='';
    case 'directbk'

        trialStep.useDirect=true;
        trialStep.bkCount=trialStep.bkCount+1;
        [trialStep.beta,trialStep.betaInit]=backtrack(trialStep.bkCount,trialStep.prevUseDirect,...
        trRadius,trialStep.betaInit,trialStep.alpha_s*trialStep.direct(1:nPrimal,1));
        trialStep.primal=trialStep.beta*trialStep.alpha_s*trialStep.direct(1:nPrimal,1);
        trialStep.dual=trialStep.beta*trialStep.alpha_z*trialStep.direct(nPrimal+1:end,1);
        c_pred=trialStep.beta*trialStep.alpha_s*norm(c_ip);
        innerIter_prnt=[trialStep.bkCount,0];legend_prnt='';
    otherwise
        error(message('optim:computeTrialStep:UnknownTrialStepType'))
    end
