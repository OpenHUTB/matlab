function[xCurrent,fval,exitflag,output,lambda,grad,Hess]=...
    barrier(funfcn,xCurrent,Ain,bin,Aeq,beq,lb,ub,confcn,hessfcn,...
    fval,grad,cIneq,cEq,JacCineqTrans,JacCeqTrans,Hess,...
    xIndices,options,finDiffFlags,makeExitMsg,varargin)
















    if~isfinite(fval)||~isreal(fval)
        error(message('optim:barrier:UsrObjUndefAtX0'))
    end
    if any(~isfinite([cIneq;cEq]))||~isreal([cIneq;cEq])
        error(message('optim:barrier:UsrNonlConstrUndefAtX0'))
    end




    fval=full(fval);



    if any(~isfinite(grad))||~isreal(grad)
        error('optim:barrier:GradUndefAtX0',...
        getString(message('optimlib:commonMsgs:GradUndefAtX0','Fmincon')));
    elseif any(~isfinite(nonzeros(JacCineqTrans)))||~isreal(JacCineqTrans)
        error('optim:barrier:DerivIneqUndefAtX0',...
        getString(message('optimlib:commonMsgs:DerivIneqUndefAtX0','Fmincon')));
    elseif any(~isfinite(nonzeros(JacCeqTrans)))||~isreal(JacCeqTrans)
        error('optim:barrier:DerivEqUndefAtX0',...
        getString(message('optimlib:commonMsgs:DerivEqUndefAtX0','Fmincon')));
    end


    constants.bndryThresh=0.995;
    honorIneqsBndsTol=0.0;


    [verbosity,detailedExitMsg]=printLevel(options.Display);


    sizes=setSizes(xCurrent,cEq,cIneq,Aeq,Ain,xIndices,false);


    nVar=sizes.nVar;mEq=sizes.mEq;mIneq=sizes.mIneq;
    nPrimal=sizes.nPrimal;nFiniteLb=sizes.nFiniteLb;
    nFiniteUb=sizes.nFiniteUb;
    nonlinEq_start=sizes.nonlinEq_start;
    nonlinEq_end=sizes.nonlinEq_end;
    nonlinIneq_start=sizes.nonlinIneq_start;
    mNonlinEq=sizes.mNonlinEq;mNonlinIneq=sizes.mNonlinIneq;
    mLinEq=sizes.mLinEq;mLinIneq=sizes.mLinIneq;





    if strcmpi(options.IpAlgorithm,'cg')||mIneq==0
        if verbosity>=4
            fprintf(getString(message('optim:barrier:AutoSwitchMonotoneMode')));
        end
        options.BarrierParamUpdate='monotone';
    end


    if verbosity>=4
        displayProblemInfo(sizes);
    end



    cIneqTrial=zeros(mNonlinIneq,1);
    cEqTrial=zeros(mNonlinEq,1);








    if strcmp(confcn{1},'fun')&&~issparse(cIneq)
        JacCineqTransTrial=zeros(nVar,mNonlinIneq);
    else
        JacCineqTransTrial=sparse(nVar,mNonlinIneq);
    end

    if strcmp(confcn{1},'fun')&&~issparse(cEq)
        JacCeqTransTrial=zeros(nVar,mNonlinEq);
    else
        JacCeqTransTrial=sparse(nVar,mNonlinEq);
    end
    gradTrial=zeros(nVar,1);




    Ain=-Ain;bin=-bin;
    cIneq=-cIneq;


    if isempty(Ain)
        Ain=reshape(Ain,0,nVar);
        bin=reshape(bin,0,1);
    end
    if isempty(Aeq)
        Aeq=reshape(Aeq,0,nVar);
        beq=reshape(beq,0,1);
    end


    xCurrent=xCurrent(:);


    outputfcn=options.OutputFcn;
    if isempty(outputfcn)
        haveoutputfcn=false;
    else
        haveoutputfcn=true;

        outputfcn=createCellArrayOfFunctions(options.OutputFcn,'OutputFcn');
    end


    plotfcns=options.PlotFcns;
    if isempty(plotfcns)
        haveplotfcn=false;
    else
        haveplotfcn=true;

        plotfcns=createCellArrayOfFunctions(options.PlotFcns,'PlotFcns');
    end



    userInterfaceFcn=@nlpInterfaceFcn;



    finDiffFlags.chkFunEval=true;
    finDiffFlags.chkComplexObj=true;




    finDiffFlags.scaleObjConstr=false;




    funcCount=1;




    fscale=[];
    [grad,JacCineqTrans,JacCeqTrans,numEvals,evalOK]=computeFinDiffGradAndJac(xCurrent,...
    funfcn,confcn,fval,-cIneq,cEq,grad,JacCineqTrans,JacCeqTrans,...
    lb,ub,fscale,options,finDiffFlags,sizes,varargin{:});
    funcCount=funcCount+numEvals;



    if~evalOK
        error('optim:barrier:DerivUndefAtX0',...
        getString(message('optimlib:commonMsgs:FinDiffDerivUndefAtX0','Fmincon')));
    end

    JacCineqTrans=-JacCineqTrans;



    finDiffFlags.scaleObjConstr=strcmpi(options.ScaleProblem,'obj-and-constr');



    if finDiffFlags.scaleObjConstr
        fscale=formScaling(grad,Ain,Aeq,JacCineqTrans,JacCeqTrans,sizes);
        Aeq=spdiags(fscale.constr(1:mLinEq,1),0,mLinEq,mLinEq)*Aeq;
        beq=fscale.constr(1:mLinEq,1).*beq;
        Ain=spdiags(fscale.constr(mEq+1:mEq+mLinIneq,1),0,mLinIneq,mLinIneq)*Ain;
        bin=fscale.constr(mEq+1:mEq+mLinIneq,1).*bin;
        fval=fscale.obj*fval;
        grad=fscale.obj*grad;
        cEq=fscale.cEq.*cEq;
        JacCeqTrans=JacCeqTrans*spdiags(fscale.cEq,0,mNonlinEq,mNonlinEq);
        cIneq=fscale.cIneq.*cIneq;
        JacCineqTrans=JacCineqTrans*spdiags(fscale.cIneq,0,mNonlinIneq,mNonlinIneq);
    else
        fscale.obj=[];fscale.constr=[];fscale.cEq=[];fscale.cIneq=[];
    end



    [cEq_all,cIneq_all]=formConstraints(xCurrent,xIndices,Aeq,beq,Ain,bin,lb,ub,cEq,cIneq);


    barrIter=0;
    iter=0;
    totalBacktrackCount=0;
    totalProjCGIter=0;
    KKTfactor=[];

















    if strcmpi(options.AlwaysHonorConstraints,'bounds-ineqs')&&mIneq>0
        if min(cIneq_all)>honorIneqsBndsTol
            honorIneqsBndsMode=true;

            if verbosity>=4
                fprintf(getString(message('optim:barrier:EnterHonorIneqsBndsMode')));
            end
        else
            honorIneqsBndsMode=false;

        end
    else
        honorIneqsBndsMode=false;

    end
    if strcmpi(options.AlwaysHonorConstraints,'bounds')||...
        (strcmpi(options.AlwaysHonorConstraints,'bounds-ineqs')&&~honorIneqsBndsMode)
        honorBndsOnlyMode=true;
    else
        honorBndsOnlyMode=false;
    end

    [slacks,trRadius,barrierParam,penaltyParam,penaltyParamMin,trialStep,constrGradNormsSquared]=...
    initialization(options,sizes,Aeq,Ain,cIneq_all,honorBndsOnlyMode,honorIneqsBndsMode);
    barrierParam_prev=barrierParam;


    f_ip=fval-barrierParam*sum(log(slacks));
    scaledGrad_ip=[grad;-barrierParam*ones(mIneq,1)];


    c_ip=[cEq_all;cIneq_all-slacks];
    [JacTrans_ip,constrGradNorms_ip]=formJacobian(xIndices,Aeq,Ain,JacCeqTrans,JacCineqTrans,...
    constrGradNormsSquared,slacks,sizes);
    cTrial_ip=c_ip;



    CompactAugMatrix=[];AugFactor=[];
    [CompactAugMatrix,AugFactor]=formAndFactorAugMatrix(CompactAugMatrix,AugFactor,...
    JacTrans_ip,slacks,Inf,barrierParam,sizes,options);
    augFactorsUpToDate=true;
    computeBarrierMults=true;
    [lambda_ip,lambdaBarrierStopTest]=leastSquaresLagrangeMults(AugFactor,grad,...
    slacks,barrierParam,computeBarrierMults,sizes);


    lambda_ip=min(lambda_ip,1e6);
    lambda_ip(mEq+1:end,1)=max(lambda_ip(mEq+1:end,1),0.1);
    lambdaTrial_ip=lambda_ip;
    mu=NaN;
    muTrial=NaN;




    if~strcmpi(options.ScaleProblem,'obj-and-constr')
        optimRelativeFactor=max(1,norm(grad,inf));
    else
        optimRelativeFactor=max(1,norm(grad/fscale.obj,inf));
    end

    optimRelativeFactor_scaled=max(1,norm(grad,inf));

    if~isfinite(optimRelativeFactor)





        optimRelativeFactor=1;
        optimRelativeFactor_scaled=1;
    end



    [done,exitflag,messageData,xCurrentIsFeasible,nlpPrimalFeasError,nlpDualFeasError,...
    nlpComplemError,lambdaStopTest,lambdaStopTestPrev]=nlpStopTest(...
    xCurrent,lambda_ip,fval,grad,JacTrans_ip,cEq_all,cIneq_all,c_ip,...
    constrGradNorms_ip,AugFactor,slacks,barrierParam,[],trialStep.useDirect,...
    iter,funcCount,[],optimRelativeFactor,[],evalOK,fscale,sizes,verbosity,...
    detailedExitMsg,options);
    KKT_error=max([nlpPrimalFeasError,nlpDualFeasError,nlpComplemError]);







    stateFeas=struct('switchViolations',0,...
    'latestPrimalFeasError',[nlpPrimalFeasError;nlpPrimalFeasError],...
    'enabled',false);



    feasRelativeFactor=max(1,nlpPrimalFeasError);

    if~strcmpi(options.ScaleProblem,'obj-and-constr')
        feasRelativeFactor_scaled=feasRelativeFactor;
    else
        nlpPrimalFeasError_scaled=max(norm(cEq_all,Inf),norm(max(-cIneq_all,0),inf));
        feasRelativeFactor_scaled=max(1,nlpPrimalFeasError_scaled);
    end



    if~done&&mIneq>0
        [barrierParam,barrierParam_prev,barrIter,...
        penaltyParamMin,trRadius,trialStep.prevUseDirect,f_ip,scaledGrad_ip]=...
        barrierTestAndUpdate(barrierParam,lambda_ip,lambdaBarrierStopTest,c_ip,...
        scaledGrad_ip,JacTrans_ip,feasRelativeFactor_scaled,optimRelativeFactor_scaled,...
        trialStep.useDirect,fval,slacks,grad,barrierParam_prev,barrIter,penaltyParamMin,...
        trRadius,trialStep.prevUseDirect,f_ip,sizes,options);
    end


    if isempty(Hess)&&~strcmpi(options.HessType,'fin-diff-grads')&&~strcmpi(options.HessType,'hessmult')
        Hess=computeHessian(hessfcn,xCurrent,lambda_ip,[],[],[],...
        funfcn,confcn,grad,JacCeqTrans,JacCineqTrans,lb,ub,xIndices,iter,fscale,...
        sizes,options,varargin{:});


        if strcmpi(options.HessType,'user-supplied')&&~isempty(isoptimargdbl('FMINCON',{'H'},Hess))
            error('optim:barrier:NonDoubleFunVal',...
            getString(message('optimlib:commonMsgs:NonDoubleFunVal','FMINCON')));
        end
    end

    barrierHess_s=slacks.*lambda_ip(mEq+1:end,1);


    if strcmpi(options.HessType,'bfgs')||strcmpi(options.HessType,'lbfgs')
        grad_old=grad;JacCeqTrans_old=JacCeqTrans;JacCineqTrans_old=JacCineqTrans;
    end



    if verbosity>=3||haveoutputfcn||haveplotfcn
        objScalingFactor=computeObjScalingFactor(options,fscale);
    end


    stop=userInterfaceFcn('init');
    if stop
        return
    end


    while~done
        iter=iter+1;


        stepAccept=false;stepTooSmall=false;c_pred=[];
        if strcmpi(options.BarrierParamUpdate,'predictor-corrector')

        elseif strcmpi(options.IpAlgorithm,'direct')

            trialStep.type='direct';
        elseif~strcmpi(trialStep.type,'cgfeas')
            trialStep.type='cg';
        end


        trialStep.bkCount=0;trialStep.beta=1;trialStep.betaInit=[];
        trialStep.projCGIter=0;

        constrIsUndefined=false;
        objIsUndefined=false;



        if~strcmpi(trialStep.type,'cgfeas')
            stateFeas.latestPrimalFeasError=[stateFeas.latestPrimalFeasError(2);...
            nlpPrimalFeasError];



        end


        while~stepAccept&&~stepTooSmall&&funcCount<options.MaxFunEvals



            if~strcmpi(trialStep.type,'pc')&&strcmpi(options.BarrierParamUpdate,'predictor-corrector')
                barrierParam=barrierAdaptiveUpdate(lambda_ip,slacks,sizes,options);
                f_ip=fval-barrierParam*sum(log(slacks));
                scaledGrad_ip(sizes.nVar+1:sizes.nPrimal)=-barrierParam;
            end





            [trialStep,c_pred,KKTfactor,CompactAugMatrix,AugFactor,augFactorsUpToDate,...
            funcCount,innerIter_prnt,legend_prnt,barrierParam,stateFeas]=...
            computeTrialStep(trialStep,Hess,barrierHess_s,JacTrans_ip,...
            scaledGrad_ip,lambda_ip,c_ip,lambdaTrial_ip,cTrial_ip,xCurrent,lb,ub,...
            xIndices,grad,JacCeqTrans,JacCineqTrans,fscale,constrGradNorms_ip,...
            c_pred,KKT_error,KKTfactor,CompactAugMatrix,AugFactor,augFactorsUpToDate,...
            slacks,barrierParam,trRadius,funcCount,honorBndsOnlyMode,honorIneqsBndsMode,...
            constants,options,sizes,funfcn,confcn,iter,...
            stateFeas,nlpPrimalFeasError,varargin{:});

            trialStep.type_prnt=trialStep.type;



            if(strcmpi(options.AlwaysHonorConstraints,'bounds')||strcmpi(options.AlwaysHonorConstraints,'bounds-ineqs'))...
                &&~strcmpi(trialStep.type,'cgfeas')
                trialStep=xFixedAndBounds(xCurrent,xIndices,trialStep,lb,ub,sizes);
            end




            if~trialStep.autoReject


                if strcmpi(options.BarrierParamUpdate,'predictor-corrector')
                    f_ip=fval-barrierParam*sum(log(slacks));
                    scaledGrad_ip(sizes.nVar+1:sizes.nPrimal)=-barrierParam;
                end

                if~strcmpi(trialStep.type,'directsoc')&&~strcmpi(trialStep.type,'cgsoc')
                    if~strcmpi(trialStep.type,'cgfeas')
                        [penaltyParamTrial,modelDecrease,numFunEvals]=updatePenaltyParam(penaltyParam,...
                        penaltyParamMin,trialStep.primal,c_pred,scaledGrad_ip,Hess,barrierHess_s,...
                        barrIter,funfcn,confcn,xCurrent,grad,JacCeqTrans,JacCineqTrans,lb,ub,...
                        xIndices,fscale,lambda_ip,options,sizes,trialStep.useDirect,varargin{:});
                    else
                        [penaltyParamTrial,modelDecrease,numFunEvals]=updatePenaltyParam(penaltyParam,...
                        penaltyParamMin,trialStep.stepFeas,stateFeas.c_pred,stateFeas.scaledGrad_ip,...
                        [],[],barrIter,[],[],[],[],[],[],[],[],[],[],[],[],stateFeas.sizes,trialStep.useDirect,...
                        varargin{:});
                    end
                    funcCount=funcCount+numFunEvals;
                end

                xTrial=xCurrent+trialStep.primal(1:nVar);




                if~strcmpi(trialStep.type,'cgfeas')

                    slacksTrial=slacks+slacks.*trialStep.primal(nVar+1:nPrimal,1);
                else

                    slacksTrial=stateFeas.slacksTrial(stateFeas.xIndices.ineq);
                end



                if trialStep.useDirect
                    lambdaTrial_ip=lambda_ip+trialStep.dual;
                end



                if strcmp(confcn{1},'fun')||strcmp(confcn{1},'fun_then_grad')
                    [cIneqTrial(:),cEqTrial(:)]=feval(confcn{3},reshape(xTrial,sizes.xShape),varargin{:});
                    if strcmpi(options.ScaleProblem,'obj-and-constr')
                        if mNonlinIneq>0,cIneqTrial=fscale.cIneq.*cIneqTrial;end
                        if mNonlinEq>0,cEqTrial=fscale.cEq.*cEqTrial;end
                    end
                elseif strcmp(confcn{1},'fungrad')
                    [cIneqTrial(:),cEqTrial(:),JacCineqTransTrial(:),JacCeqTransTrial(:)]=...
                    feval(confcn{3},reshape(xTrial,sizes.xShape),varargin{:});
                    if strcmpi(options.ScaleProblem,'obj-and-constr')
                        if mNonlinIneq>0,cIneqTrial=fscale.cIneq.*cIneqTrial;end
                        if mNonlinEq>0,cEqTrial=fscale.cEq.*cEqTrial;end
                        JacCeqTransTrial=JacCeqTransTrial*spdiags(fscale.cEq,0,mNonlinEq,mNonlinEq);
                        JacCineqTransTrial=JacCineqTransTrial*spdiags(fscale.cIneq,0,mNonlinIneq,mNonlinIneq);
                    end
                else
                    cIneqTrial=zeros(0,1);cEqTrial=zeros(0,1);
                end
                funcCount=funcCount+1;


                cIneqTrial=-cIneqTrial;


                [cEqTrial_all,cIneqTrial_all]=formConstraints(xTrial,xIndices,...
                Aeq,beq,Ain,bin,lb,ub,cEqTrial,cIneqTrial);


                funcEvalWellDefined=true;
                if any(~isfinite([cIneqTrial;cEqTrial]))||~isreal([cIneqTrial;cEqTrial])
                    funcEvalWellDefined=false;
                    if verbosity>=3
                        constrIsUndefined=true;
                        if any(isnan([cIneqTrial;cEqTrial]))
                            undefValue='NaN';
                        elseif any(~isfinite([cIneqTrial;cEqTrial]))
                            undefValue='Inf';
                        else
                            undefValue='complex';
                        end
                    end
                end




                if funcEvalWellDefined&&(~honorIneqsBndsMode||min(cIneqTrial_all)>0)
                    if~strcmp(funfcn{1},'fungrad')
                        fvalTrial=feval(funfcn{3},reshape(xTrial,sizes.xShape),varargin{:});
                        if strcmpi(options.ScaleProblem,'obj-and-constr')
                            fvalTrial=fscale.obj*fvalTrial;
                        end
                    else
                        [fvalTrial,gradTrial(:)]=feval(funfcn{3},reshape(xTrial,sizes.xShape),varargin{:});
                        if strcmpi(options.ScaleProblem,'obj-and-constr')
                            fvalTrial=fscale.obj*fvalTrial;gradTrial=fscale.obj*gradTrial;
                        end
                    end


                    if~isfinite(fvalTrial)||~isreal(fvalTrial)
                        funcEvalWellDefined=false;
                        if verbosity>=3
                            objIsUndefined=true;
                            if isnan(fvalTrial)
                                undefValue='NaN';
                            elseif~isfinite(fvalTrial)
                                undefValue='Inf';
                            else
                                undefValue='complex';
                            end
                        end
                    end
                else

                    fvalTrial=fval;
                end





                fvalTrial=full(fvalTrial);





                if~funcEvalWellDefined

                    trialStep.autoReject=true;


                    modelDecrease=0;meritDecrease=-1;
                    fTrial_ip=f_ip;
                elseif honorIneqsBndsMode&&min(cIneqTrial_all)<=0



                    modelDecrease=0;meritDecrease=-1;
                    fTrial_ip=f_ip;



                    cTrial_ip=[cEqTrial_all;cIneqTrial_all-slacksTrial];
                else

                    if options.ResetAllValid




                        ind=cIneqTrial_all>0;
                        slacksTrial(ind)=cIneqTrial_all(ind);



                    else
                        slacksTrial=max(slacksTrial,cIneqTrial_all);
                    end

                    if honorIneqsBndsMode
                        slacksTrial=cIneqTrial_all;
                    elseif honorBndsOnlyMode
                        slacksTrial(mLinIneq+1:mLinIneq+nFiniteLb+nFiniteUb,1)=...
                        cIneqTrial_all(mLinIneq+1:mLinIneq+nFiniteLb+nFiniteUb,1);
                    end

                    fTrial_ip=fvalTrial-barrierParam*sum(log(slacksTrial));
                    cTrial_ip=[cEqTrial_all;cIneqTrial_all-slacksTrial];


                    if~strcmpi(trialStep.type,'cgfeas')
                        infeasibilityDecrease=norm(c_ip)-norm(cTrial_ip);
                        meritDecrease=f_ip-fTrial_ip+penaltyParamTrial*infeasibilityDecrease;
                    else
                        relaxEqPlusTrial=stateFeas.relaxTrial(stateFeas.xIndices.eqPlus);
                        relaxEqMinusTrial=stateFeas.relaxTrial(stateFeas.xIndices.eqMinus);
                        relaxIneqTrial=stateFeas.relaxTrial(stateFeas.xIndices.ineq);

                        slacksRelaxEqPlusTrial=stateFeas.slacksTrial(stateFeas.xIndices.eqPlus);
                        slacksRelaxEqMinusTrial=stateFeas.slacksTrial(stateFeas.xIndices.eqMinus);
                        slacksIneqTrial=stateFeas.slacksTrial(stateFeas.xIndices.ineq);
                        slacksRelaxIneqTrial=stateFeas.slacksTrial(stateFeas.xIndices.relaxIneq);

                        cFeasTrial=[cEqTrial_all-relaxEqPlusTrial+relaxEqMinusTrial;...
                        cIneqTrial_all+relaxIneqTrial-slacksIneqTrial;...
                        relaxEqPlusTrial-slacksRelaxEqPlusTrial;...
                        relaxEqMinusTrial-slacksRelaxEqMinusTrial;...
                        relaxIneqTrial-slacksRelaxIneqTrial];
                        infeasibilityDecrease=norm(stateFeas.cFeas)-norm(cFeasTrial);
                        objectiveDecrease=-sum(stateFeas.drelax)...
                        -barrierParam*log(prod(stateFeas.slacks./stateFeas.slacksTrial));
                        modelDecrease=stateFeas.obj_pred+penaltyParamTrial*stateFeas.c_pred;
                        meritDecrease=objectiveDecrease+penaltyParamTrial*infeasibilityDecrease;






                    end
                end

                if strcmpi(trialStep.type,'pc')
                    mu=dot(lambda_ip(mEq+1:end,1),slacks)/mIneq;
                    muTrial=dot(lambdaTrial_ip(mEq+1:end,1),slacksTrial)/mIneq;





                    if muTrial>options.DeltaComplThresh*mu
                        trialStep.autoReject=true;
                    end
                end

            else


                modelDecrease=0;meritDecrease=-1;
                fTrial_ip=f_ip;
            end


            [stepAccept,trialStep.type,trRadius,stepTooSmall]=acceptanceTest(...
            meritDecrease,modelDecrease,xCurrent,trialStep,f_ip,fTrial_ip,trRadius,...
            options,sizes);


            if~stepAccept




                userInterfaceFcn('rejectedStep');
            end

        end
        totalBacktrackCount=totalBacktrackCount+trialStep.bkCount;
        totalProjCGIter=totalProjCGIter+trialStep.projCGIter;


        if~stepAccept
            if stepTooSmall
                if xCurrentIsFeasible

                    exitflag=2;
                    messageData={{'optimlib:sqpLineSearch:Exit2basic','fmincon'},...
                    {'optimlib:sqpLineSearch:Exit2detailed',...
                    options.TolX,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
                    verbosity>=2,detailedExitMsg};
                else

                    exitflag=-2;

                    messageData={{'optimlib:sqpLineSearch:ExitNeg22basic','fmincon'},...
                    {'optimlib:sqpLineSearch:ExitNeg22detailed',...
                    options.TolX,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
                    verbosity>=1,detailedExitMsg};
                end
            elseif funcCount>=options.MaxFunEvals
                exitflag=0;
                messageData={{'optimlib:commonMsgs:Exit0basic','fmincon',options.MaxFunEvals},...
                {},verbosity>=1,false};
            end


            if verbosity>=3
                displayUndefinedValueMsg;
            end
            break
        end


        [gradTrial,JacCineqTransTrial,JacCeqTransTrial,numEvals,evalOK]=...
        computeFinDiffGradAndJac(xTrial,funfcn,confcn,fvalTrial,-cIneqTrial,cEqTrial,...
        gradTrial,JacCineqTransTrial,JacCeqTransTrial,...
        lb,ub,fscale,options,finDiffFlags,sizes,varargin{:});
        funcCount=funcCount+numEvals;




        if~evalOK
            gradTrial=grad_old;
            JacCineqTransTrial=JacCineqTrans_old;
            JacCeqTransTrial=JacCeqTrans_old;
        end


        if strcmp(funfcn{1},'fun_then_grad')
            gradTrial(:)=feval(funfcn{4},reshape(xTrial,sizes.xShape),varargin{:});
            if strcmpi(options.ScaleProblem,'obj-and-constr')
                gradTrial=fscale.obj*gradTrial;
            end
        end
        if strcmp(confcn{1},'fun_then_grad')
            [JacCineqTransTrial(:),JacCeqTransTrial(:)]=feval(confcn{4},...
            reshape(xTrial,sizes.xShape),varargin{:});
            if strcmpi(options.ScaleProblem,'obj-and-constr')
                JacCeqTransTrial=JacCeqTransTrial*spdiags(fscale.cEq,0,mNonlinEq,mNonlinEq);
                JacCineqTransTrial=JacCineqTransTrial*spdiags(fscale.cIneq,0,mNonlinIneq,mNonlinIneq);
            end
        end


        penaltyParam=penaltyParamTrial;
        xCurrent=xTrial;slacks=slacksTrial;
        fval=fvalTrial;f_ip=fTrial_ip;
        if strcmpi(options.BarrierParamUpdate,'predictor-corrector')
            mu=muTrial;
        end
        if strcmpi(trialStep.type,'cgfeas')
            stateFeas.relaxEqPlus=relaxEqPlusTrial;
            stateFeas.relaxEqMinus=relaxEqMinusTrial;
            stateFeas.relaxIneq=relaxIneqTrial;
            stateFeas.slacks=stateFeas.slacksTrial;














        end

        cIneq_all=cIneqTrial_all;cEq_all=cEqTrial_all;c_ip=cTrial_ip;

        grad=gradTrial;JacCineqTrans=JacCineqTransTrial;JacCeqTrans=JacCeqTransTrial;

        JacCineqTrans=-JacCineqTrans;

        scaledGrad_ip=[grad;-barrierParam*ones(mIneq,1)];
        [JacTrans_ip,constrGradNorms_ip]=formJacobian(xIndices,Aeq,Ain,JacCeqTrans,JacCineqTrans,...
        constrGradNormsSquared,slacks,sizes);
        augFactorsUpToDate=false;


        if strcmpi(options.AlwaysHonorConstraints,'bounds-ineqs')&&~honorIneqsBndsMode&&mIneq>0
            if min(cIneq_all)>honorIneqsBndsTol

                honorIneqsBndsMode=true;
                honorBndsOnlyMode=false;


                slacks=cIneq_all;
                if verbosity>=4
                    fprintf(getString(message('optim:barrier:EnterHonorIneqsBndsMode')));
                end
            end
        end


        if trialStep.useDirect
            lambda_ip=lambdaTrial_ip;
            trialStep.prevUseDirect=true;
        else


            [CompactAugMatrix,AugFactor]=formAndFactorAugMatrix(CompactAugMatrix,AugFactor,...
            JacTrans_ip,slacks,KKT_error,barrierParam,sizes,options);
            augFactorsUpToDate=true;
            computeBarrierMults=true;
            [lambda_ip,lambdaBarrierStopTest]=leastSquaresLagrangeMults(AugFactor,grad,...
            slacks,barrierParam,computeBarrierMults,sizes);
            trialStep.prevUseDirect=false;
        end


        if strcmpi(options.HessType,'bfgs')||strcmpi(options.HessType,'lbfgs')



            delta_gradLag=grad-grad_old...
            -(JacCeqTrans-JacCeqTrans_old)*lambda_ip(nonlinEq_start:nonlinEq_end,1)...
            -(JacCineqTrans-JacCineqTrans_old)*lambda_ip(nonlinIneq_start:end,1);

            grad_old=grad;JacCeqTrans_old=JacCeqTrans;JacCineqTrans_old=JacCineqTrans;
        else
            delta_gradLag=[];
        end



        if~strcmpi(options.HessType,'fin-diff-grads')&&~strcmpi(options.HessType,'hessmult')
            Hess=computeHessian(hessfcn,xCurrent,lambda_ip,trialStep.primal(1:nVar),...
            delta_gradLag,Hess,funfcn,confcn,grad,JacCeqTrans,JacCineqTrans,lb,ub,...
            xIndices,iter,fscale,sizes,options,varargin{:});
        end
        barrierHess_s=slacks.*lambda_ip(mEq+1:end,1);


        trRadius=accStepTRupdate(trRadius,trialStep,modelDecrease,meritDecrease);


        barrIter=barrIter+1;


        if~strcmpi(options.ScaleProblem,'obj-and-constr')
            optimRelativeFactor=max(1,norm(grad,inf));
        else
            optimRelativeFactor=max(1,norm(grad/fscale.obj,inf));
        end

        optimRelativeFactor_scaled=max(1,norm(grad,inf));

        if~isfinite(optimRelativeFactor)





            optimRelativeFactor=1;
            optimRelativeFactor_scaled=1;
        end



        [done,exitflag,messageData,xCurrentIsFeasible,nlpPrimalFeasError,nlpDualFeasError,...
        nlpComplemError,lambdaStopTest,lambdaStopTestPrev]=nlpStopTest(...
        xCurrent,lambda_ip,fval,grad,JacTrans_ip,cEq_all,cIneq_all,c_ip,...
        constrGradNorms_ip,AugFactor,slacks,barrierParam,trialStep.primal(1:nVar),...
        trialStep.useDirect,iter,funcCount,feasRelativeFactor,optimRelativeFactor,...
        lambdaStopTestPrev,evalOK,fscale,sizes,verbosity,detailedExitMsg,options);





        if strcmpi(trialStep.type,'cgfeas')&&~done

            computeBarrierMults=true;
            [stateFeas.lambda_ip,stateFeas.lambdaBarrierStopTest]=leastSquaresLagrangeMults(stateFeas.AugFactor,...
            stateFeas.scaledGrad_ip(1:stateFeas.sizes.nVar),stateFeas.slacksTrial,...
            barrierParam,computeBarrierMults,stateFeas.sizes);

            fvalFeas=sum(stateFeas.relaxEqPlus)+sum(stateFeas.relaxEqMinus)...
            +sum(stateFeas.relaxIneq);
            gradFeas=stateFeas.scaledGrad_ip(1:stateFeas.sizes.nVar);



            [done,exitflagFeas]=nlpStopTest(stateFeas.xFeas,stateFeas.lambda_ip,fvalFeas,gradFeas,...
            stateFeas.jacFeasTrans,stateFeas.cEq_all,stateFeas.cIneq_all,stateFeas.cFeas,...
            stateFeas.constrGradNormsFeas,stateFeas.AugFactor,stateFeas.slacks,...
            barrierParam,trialStep.stepFeas(1:stateFeas.sizes.nVar),trialStep.useDirect,...
            iter,funcCount,feasRelativeFactor,optimRelativeFactor,stateFeas.lambda_ip,...
            evalOK,fscale,stateFeas.sizes,verbosity,detailedExitMsg,options);
            if exitflagFeas==1



                barrierParam=barrierParam*0.2;
                [done,~,~,~,nlpPrimalFeasError,nlpDualFeasError,nlpComplemError]=nlpStopTest(...
                xCurrent,lambda_ip,fval,grad,JacTrans_ip,cEq_all,cIneq_all,c_ip,...
                constrGradNorms_ip,AugFactor,slacks,barrierParam,trialStep.primal(1:nVar),...
                trialStep.useDirect,iter,funcCount,feasRelativeFactor,optimRelativeFactor,...
                lambdaStopTestPrev,evalOK,fscale,sizes,verbosity,detailedExitMsg,options);
            end

            if strcmpi(options.EnableFeasibilityMode,'always')...
                &&nlpPrimalFeasError<options.TolCon*feasRelativeFactor
                done=true;
                exitflag=1;
                messageData={{replace('optimlib:sqpLineSearch:Exit1detailed','detailed','basic')},...
                {'optimlib:sqpLineSearch:Exit1detailed',...
                max(nlpDualFeasError/optimRelativeFactor,nlpComplemError/optimRelativeFactor),...
                options.TolFun,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
                verbosity>=2,detailedExitMsg};
            elseif done||norm(stateFeas.drelax,1)<options.FeasModeRelaxTol*fvalFeas





                done=true;


                exitflag=-2;

                messageData={{'optimlib:sqpLineSearch:ExitNeg2feasibility'},...
                {'optimlib:sqpLineSearch:ExitNeg2feasibility'},verbosity>=2,detailedExitMsg};
            end
        end
        KKT_error=max([nlpPrimalFeasError,nlpDualFeasError,nlpComplemError]);



        stop=userInterfaceFcn('iter');
        if stop
            return
        end


        if~done&&(mIneq>0...
            ||strcmpi(options.EnableFeasibilityMode,'always')...
            ||options.EnableFeasibilityMode)






            if strcmpi(trialStep.type,'cgfeas')



                [barrierParam,barrierParam_prev,barrIter,penaltyParamMin,trRadius,...
                trialStep.prevUseDirect,f_ip,stateFeas.scaledGrad_ip]=...
                barrierTestAndUpdate(barrierParam,stateFeas.lambda_ip,stateFeas.lambdaBarrierStopTest,...
                stateFeas.cFeas,stateFeas.scaledGrad_ip,stateFeas.jacFeasTrans,...
                feasRelativeFactor_scaled,optimRelativeFactor_scaled,trialStep.useDirect,...
                fval,slacks,stateFeas.scaledGrad_ip(1:stateFeas.sizes.nPrimal),...
                barrierParam_prev,barrIter,penaltyParamMin,trRadius,...
                trialStep.prevUseDirect,f_ip,stateFeas.sizes,options);
            elseif strcmpi(options.BarrierParamUpdate,'monotone')

                [barrierParam,barrierParam_prev,barrIter,...
                penaltyParamMin,trRadius,trialStep.prevUseDirect,f_ip,scaledGrad_ip]=...
                barrierTestAndUpdate(barrierParam,lambda_ip,lambdaBarrierStopTest,c_ip,...
                scaledGrad_ip,JacTrans_ip,feasRelativeFactor_scaled,optimRelativeFactor_scaled,...
                trialStep.useDirect,fval,slacks,grad,barrierParam_prev,barrIter,penaltyParamMin,...
                trRadius,trialStep.prevUseDirect,f_ip,sizes,options);
            else





                penaltyParamMin=100*norm(c_ip);
                trRadius=max(5*trRadius,1);


                trialStep.type='pc';
            end
        end
    end



    output.iterations=iter;
    output.funcCount=funcCount;
    output.constrviolation=nlpPrimalFeasError;
    output.stepsize=norm(trialStep.primal(1:nVar));
    output.algorithm='interior-point';
    output.firstorderopt=max(nlpDualFeasError,nlpComplemError);
    output.cgiterations=totalProjCGIter;



    userInterfaceFcn('done');


    if strcmpi(options.HessType,'lbfgs')||strcmpi(options.HessType,'fin-diff-grads')...
        ||strcmpi(options.HessType,'hessmult')
        Hess=[];
    end


    if strcmpi(options.ScaleProblem,'obj-and-constr')


        if fscale.objIsScaled
            fval=fval/fscale.obj;
            grad=grad/fscale.obj;
            if~isempty(Hess)
                Hess=Hess/fscale.obj;
            end
        end
        lambdaStopTest=(fscale.constr.*lambdaStopTest)/fscale.obj;
    end

    xCurrent=reshape(xCurrent,sizes.xShape);

    lambda=formLambdaStruct(lambdaStopTest,grad,xIndices,sizes,false);


    if makeExitMsg
        output.message=createExitMsg(messageData{:});
        if islogical(options.EnableFeasibilityMode)&&~options.EnableFeasibilityMode...
            &&exitflag==-2
            messageData{1}={'optimlib:sqpLineSearch:ExitNeg2considerfeas'};
            messageData{2}={'optimlib:sqpLineSearch:ExitNeg2considerfeas'};
            messageData{4}=1;
            createExitMsg(messageData{:});
        end
    end


    function stop=nlpInterfaceFcn(state)






        stop=false;


        switch state
        case 'init'

            if haveoutputfcn||haveplotfcn
                fvalDisp=fval/objScalingFactor;
                [optimValues,stop]=callOutputAndPlotFcns(outputfcn,plotfcns,xCurrent,...
                sizes,'init',iter,funcCount,fvalDisp,nlpPrimalFeasError,[],grad,...
                nlpDualFeasError,nlpComplemError,trRadius,0,varargin{:});



                if~stop

                    fvalDisp=fval/objScalingFactor;
                    [optimValues,stop]=callOutputAndPlotFcns(outputfcn,plotfcns,xCurrent,...
                    sizes,'iter',iter,funcCount,fvalDisp,nlpPrimalFeasError,[],grad,...
                    nlpDualFeasError,nlpComplemError,trRadius,0,varargin{:});
                end
            end


            displayHeader(verbosity);

            if verbosity>=3
                fvalDisp=fval/objScalingFactor;
                fprintf('%5.0f   %5.0f  %14.6e   %10.3e   %10.3e\n',...
                iter,funcCount,fvalDisp,nlpPrimalFeasError,max(nlpDualFeasError,nlpComplemError))
            end
        case 'rejectedStep'
            if verbosity>=4
                if trialStep.autoReject

                    fvalTrial=fval;infeasTrial=norm(c_ip);
                else
                    infeasTrial=norm(cTrial_ip);
                end
                fvalTrialDisp=fvalTrial/objScalingFactor;
                fprintf(' Rej    %5.0f  %14.6e   %10.3e                %10.3e   %5.1e %5.0f %8s %5s\n',...
                funcCount,fvalTrialDisp,infeasTrial,norm(trialStep.primal(1:nVar)),...
                barrierParam,innerIter_prnt(1),trialStep.type_prnt,legend_prnt)
            end
        case 'iter'

            if verbosity>=3



                displayUndefinedValueMsg;




                if mod(iter-1,30)==0&&iter>1
                    fprintf('\n');
                    displayHeader(verbosity);
                end

                fvalDisp=fval/objScalingFactor;
                fprintf('%5.0f   %5.0f  %14.6e   %10.3e   %10.3e   %10.3e',...
                iter,funcCount,fvalDisp,nlpPrimalFeasError,max(nlpDualFeasError,nlpComplemError),...
                norm(trialStep.primal(1:nVar)))
                if verbosity>=4
                    fprintf('   %5.1e %5.0f %8s %5s',...
                    barrierParam,innerIter_prnt(1),trialStep.type_prnt,legend_prnt)
                end
                fprintf('\n')
            end


            if haveoutputfcn||haveplotfcn
                fvalDisp=fval/objScalingFactor;
                [optimValues,stop]=callOutputAndPlotFcns(outputfcn,plotfcns,xCurrent,...
                sizes,'iter',iter,funcCount,fvalDisp,nlpPrimalFeasError,...
                trialStep.primal(1:nVar),grad,nlpDualFeasError,nlpComplemError,...
                trRadius,trialStep.projCGIter,varargin{:});
            end

        case 'done'

            if haveoutputfcn||haveplotfcn
                fvalDisp=fval/objScalingFactor;

                callOutputAndPlotFcns(outputfcn,plotfcns,xCurrent,...
                sizes,'done',iter,funcCount,fvalDisp,nlpPrimalFeasError,...
                trialStep.primal(1:nVar),grad,nlpDualFeasError,nlpComplemError,...
                trRadius,trialStep.projCGIter,varargin{:});
            end
        end


        if(haveoutputfcn||haveplotfcn)&&stop
            [xCurrent,fval,exitflag,output,lambda,grad,Hess]=...
            cleanUpInterrupt(xCurrent,optimValues,totalProjCGIter,sizes,verbosity);
            done=true;
        end
    end

    function displayUndefinedValueMsg


        if objIsUndefined
            fprintf(getString(message('optimlib:commonMsgs:ObjInfNaNComplex',undefValue)));
        elseif constrIsUndefined
            fprintf(getString(message('optimlib:commonMsgs:ConstrInfNaNComplex',undefValue)));
        end
    end

end


function[optimValues,stop]=callOutputAndPlotFcns(outputfcn,plotfcns,xCurrent,...
    sizes,state,iter,funcCount,fval,nlpPrimalFeasError,step,grad,...
    nlpDualFeasError,nlpComplemError,trRadius,projCGIter,varargin)








    optimValues.iteration=iter;
    optimValues.funccount=funcCount;
    optimValues.fval=fval;
    optimValues.constrviolation=nlpPrimalFeasError;
    optimValues.stepsize=norm(step);
    optimValues.gradient=grad;
    optimValues.firstorderopt=max(nlpDualFeasError,nlpComplemError);
    optimValues.trustregionradius=trRadius;
    optimValues.cgiterations=projCGIter;

    stop=false;
    if~isempty(outputfcn)
        switch state
        case{'iter','init','interrupt'}
            stop=callAllOptimOutputFcns(outputfcn,reshape(xCurrent,sizes.xShape),...
            optimValues,state,varargin{:})||stop;
        case 'done'
            callAllOptimOutputFcns(outputfcn,reshape(xCurrent,sizes.xShape),...
            optimValues,state,varargin{:});
        end
    end

    if~isempty(plotfcns)
        switch state
        case{'iter','init'}
            stop=callAllOptimPlotFcns(plotfcns,reshape(xCurrent,sizes.xShape),...
            optimValues,state,varargin{:})||stop;
        case 'done'
            callAllOptimPlotFcns(plotfcns,reshape(xCurrent,sizes.xShape),...
            optimValues,state,varargin{:});
        end
    end
end


function[xCurrent,fval,exitflag,output,lambda,grad,Hess]=cleanUpInterrupt(...
    xCurrent,optimValues,totalProjCGIter,sizes,verbosity)








    callAllOptimPlotFcns('cleanuponstopsignal');

    xCurrent=reshape(xCurrent,sizes.xShape);
    fval=optimValues.fval;
    exitflag=-1;
    output.iterations=optimValues.iteration;
    output.funcCount=optimValues.funccount;
    output.constrviolation=optimValues.constrviolation;
    output.stepsize=optimValues.stepsize;
    output.algorithm='interior-point';
    output.firstorderopt=optimValues.firstorderopt;
    output.cgiterations=totalProjCGIter;
    output.message=createExitMsg({'optimlib:commonMsgs:ExitNeg1basic','fmincon'},{},verbosity>=1,false);
    lambda=[];
    grad=optimValues.gradient;
    Hess=[];
end


function[verbosity,detailedExitMsg]=printLevel(Display)


    detailedExitMsg=contains(Display,'detailed');

    switch Display
    case{'off','none'}
        verbosity=0;
    case{'notify','notify-detailed'}
        verbosity=1;
    case{'final','final-detailed'}
        verbosity=2;
    case{'iter','iter-detailed'}
        verbosity=3;
    case 'testing'
        verbosity=4;
    otherwise

        verbosity=2;
    end
end


function displayHeader(verbosity)



    if verbosity>=3
        fprintf('                                            First-order      Norm of')
        if verbosity>=4
            fprintf('              CG     Step')
        end
        fprintf('\n')
        fprintf(' Iter F-count            f(x)  Feasibility   optimality         step')
        if verbosity>=4
            fprintf('        mu   its     type')
        end
        fprintf('\n')
    end
end


function objScalingFactor=computeObjScalingFactor(options,fscale)




    if strcmpi(options.ScaleProblem,'obj-and-constr')
        objScalingFactor=fscale.obj;
    else
        objScalingFactor=1.0;
    end
end


function[slacks,trRadius,barrierParam,penaltyParam,penaltyParamMin,...
    trialStep,constrGradNormsSquared]=initialization(options,sizes,...
    Aeq,Ain,cIneq_all,honorBndsOnlyMode,honorIneqsBndsMode)





    nPrimal=sizes.nPrimal;
    mAll=sizes.mAll;
    mLinIneq=sizes.mLinIneq;
    mLinEq=sizes.mLinEq;
    nFiniteLb=sizes.nFiniteLb;
    nFiniteUb=sizes.nFiniteUb;


    fixed_start=sizes.fixed_start;
    nonlinEq_start=sizes.nonlinEq_start;
    ineq_start=sizes.ineq_start;
    finiteLb_start=sizes.finiteLb_start;
    finiteUb_start=sizes.finiteUb_start;
    nonlinIneq_start=sizes.nonlinIneq_start;


    barrierParam=options.InitBarrierParam;
    trRadius=options.InitTrustRegionRadius;
    penaltyParam=1.0;
    penaltyParamMin=1.0;



    trialStep.primal=zeros(nPrimal,1);
    trialStep.dual=zeros(mAll,1);
    trialStep.direct=zeros(nPrimal+mAll,1);
    trialStep.normal=zeros(nPrimal,1);
    trialStep.tangential=zeros(nPrimal,1);
    trialStep.bkCount=0;
    trialStep.beta=1.0;
    trialStep.betaInit=0.5;
    trialStep.alpha_s=1.0;
    trialStep.alpha_z=1.0;
    trialStep.useDirect=false;




    if strcmpi(options.IpAlgorithm,'direct')
        if strcmpi(options.BarrierParamUpdate,'predictor-corrector')
            trialStep.type='pc';
        else
            trialStep.type='direct';
        end
        trialStep.prevUseDirect=true;
    else
        trialStep.type='cg';
        trialStep.prevUseDirect=false;
    end
    trialStep.autoReject=false;

    trialStep.type_prnt=trialStep.type;
    trialStep.projCGIter=0;


    slacks=max(0.1,cIneq_all);





    if honorIneqsBndsMode
        slacks=cIneq_all;
    elseif honorBndsOnlyMode
        slacks(mLinIneq+1:mLinIneq+nFiniteLb+nFiniteUb,1)=cIneq_all(mLinIneq+1:mLinIneq+nFiniteLb+nFiniteUb,1);
    end










    constrGradNormsSquared=zeros(mAll,1);
    constrGradNormsSquared(1:mLinEq)=full(sum(Aeq.^2,2));
    constrGradNormsSquared(fixed_start:nonlinEq_start-1)=1;
    constrGradNormsSquared(ineq_start:finiteLb_start-1)=full(sum(Ain.^2,2));
    constrGradNormsSquared(finiteLb_start:finiteUb_start-1)=1;
    constrGradNormsSquared(finiteUb_start:nonlinIneq_start-1)=-1;
end