function[xCurrent,fval,exitflag,output,lambda,grad,Hess]=...
    sqpLineSearch(funfcn,xCurrent,Aineq,bineq,Aeq,beq,lb,ub,confcn,fval,grad,cIneqUser,cEqUser,...
    JacCineqTransUser,JacCeqTransUser,xIndices,options,finDiffFlags,verbosity,detailedExitMsg,makeExitMsg,varargin)
















    if~isfinite(fval)||~isreal(fval)
        error('optim:sqpLineSearch:UsrObjUndefAtX0',...
        getString(message('optimlib:sqpLineSearch:UsrObjUndefAtX0')));
    end
    if any(~isfinite([cIneqUser;cEqUser]))||~isreal([cIneqUser;cEqUser])
        error('optim:sqpLineSearch:UsrNonlConstrUndefAtX0',...
        getString(message('optimlib:sqpLineSearch:UsrNonlConstrUndefAtX0')));
    end



    if any(~isfinite(grad))||~isreal(grad)
        error('optim:sqpLineSearch:GradUndefAtX0',...
        getString(message('optimlib:commonMsgs:GradUndefAtX0','Fmincon')));
    elseif any(any(~isfinite(JacCineqTransUser)))||~isreal(JacCineqTransUser)
        error('optim:sqpLineSearch:DerivIneqUndefAtX0',...
        getString(message('optimlib:commonMsgs:DerivIneqUndefAtX0','Fmincon')));
    elseif any(any(~isfinite(JacCeqTransUser)))||~isreal(JacCeqTransUser)
        error('optim:sqpLineSearch:DerivEqUndefAtX0',...
        getString(message('optimlib:commonMsgs:DerivEqUndefAtX0','Fmincon')));
    end

    if~isreal(Aineq)||~isreal(bineq)||~isreal(Aeq)||~isreal(beq)
        error('optim:sqpLineSearch:invalidLinConstr',...
        getString(message('optimlib:sqpLineSearch:invalidLinConstr')));
    end


    outputfcn=[];plotfcns=[];


    if isempty(options.OutputFcn)
        haveoutputfcn=false;
    else
        haveoutputfcn=true;

        outputfcn=createCellArrayOfFunctions(options.OutputFcn,'OutputFcn');
    end

    if isempty(options.PlotFcns)
        haveplotfcn=false;
    else
        haveplotfcn=true;

        plotfcns=createCellArrayOfFunctions(options.PlotFcns,'PlotFcns');
    end


    cEqUser=cEqUser(:);
    cIneqUser=cIneqUser(:);


    sizes=setSizes(xCurrent,cEqUser,cIneqUser,Aeq,Aineq,xIndices,true);


    sizes.nArtificialVar=sizes.mIneq+2*sizes.mEq;



    xIndices.lambdaIdx=[true(sizes.mAll,1);xIndices.finiteLb;xIndices.finiteUb];


    mEq=sizes.mEq;
    nonlinEq_end=sizes.nonlinEq_end;
    ineq_start=sizes.ineq_start;
    finiteLb_start=sizes.finiteLb_start;
    mNonlinEq=sizes.mNonlinEq;
    mNonlinIneq=sizes.mNonlinIneq;
    mLinEq=sizes.mLinEq;
    mLinIneq=sizes.mLinIneq;







    Aineq=-Aineq;bineq=-bineq;
    cIneqUser=-cIneqUser;


    xCurrent=xCurrent(:);

    [lambda,lambdaStopTest,lambdaqp,Weq,Wineq,Wlower,Wupper,steplength,iter,funcCount,...
    penaltyParam,phiInitial,phiPrimeInitial,searchDirection,socDirection,delta_x,...
    finDiffFlags,stepFlags,qpoptions,linearizedConstrViol]=initializeSQPparam(sizes,finDiffFlags,options);




    finDiffFlags.scaleObjConstr=false;




    fscale=[];
    [grad,JacCineqTransUser,JacCeqTransUser,extraEvals,evalOK]=...
    computeFinDiffGradAndJac(xCurrent,funfcn,confcn,fval,-cIneqUser,cEqUser,grad,...
    JacCineqTransUser,JacCeqTransUser,lb,ub,fscale,options,finDiffFlags,sizes,varargin{:});
    funcCount=funcCount+extraEvals;


    undefGrads=~evalOK;



    if undefGrads
        error('optim:sqpLineSearch:DerivUndefAtX0',...
        getString(message('optimlib:commonMsgs:FinDiffDerivUndefAtX0','Fmincon')));
    end

    JacCineqTransUser=-JacCineqTransUser;



    finDiffFlags.scaleObjConstr=strcmpi(options.ScaleProblem,'obj-and-constr');



    if finDiffFlags.scaleObjConstr
        fscale=formScaling(grad,Aineq,Aeq,JacCineqTransUser,JacCeqTransUser,sizes);

        fscale.constr=[fscale.constr;ones(sizes.nFiniteLb+sizes.nFiniteUb,1)];


        if mLinEq==1
            Aeq=fscale.constr(1)*Aeq;
        else
            Aeq=spdiags(fscale.constr(1:mLinEq,1),0,mLinEq,mLinEq)*Aeq;
        end
        if mLinIneq==1
            Aineq=fscale.constr(mEq+1)*Aineq;
        else
            Aineq=spdiags(fscale.constr(mEq+1:mEq+mLinIneq,1),0,mLinIneq,mLinIneq)*Aineq;
        end
        beq=fscale.constr(1:mLinEq,1).*beq;
        bineq=fscale.constr(mEq+1:mEq+mLinIneq,1).*bineq;
        fval=fscale.obj*fval;
        grad=fscale.obj*grad;
        cEqUser=fscale.cEq.*cEqUser;
        cIneqUser=fscale.cIneq.*cIneqUser;


        if mNonlinEq==1
            JacCeqTransUser=JacCeqTransUser*fscale.cEq;
        else
            JacCeqTransUser=JacCeqTransUser*spdiags(fscale.cEq,0,mNonlinEq,mNonlinEq);
        end
        if mNonlinIneq==1
            JacCineqTransUser=JacCineqTransUser*fscale.cIneq;
        else
            JacCineqTransUser=JacCineqTransUser*spdiags(fscale.cIneq,0,mNonlinIneq,mNonlinIneq);
        end
    else
        fscale=[];
    end


    cEq_all=[Aeq*xCurrent-beq
    cEqUser];


    cIneq_all=[Aineq*xCurrent-bineq
    cIneqUser];


    JacCeqTrans=[Aeq',JacCeqTransUser];
    JacCineqTrans=[Aineq',JacCineqTransUser];


    [done,exitflag,msgData,nlpPrimalFeasError,nlpDualFeasError,nlpComplemError,lambdaStopTest]=...
    stopTestSQP(xCurrent,lambda,lambdaStopTest,fval,grad,cEq_all,JacCeqTrans,cIneq_all,...
    JacCineqTrans,lb,ub,[],[],iter,funcCount,[],[],[],[],verbosity,fscale,sizes,xIndices,[],...
    undefGrads,options,detailedExitMsg);
    KKT_error=max([nlpDualFeasError,nlpComplemError]);
    feasRelativeFactor=max(1,nlpPrimalFeasError);



    Hess=computeHessian([],[],[],[],[],[],[],[],[],...
    [],[],[],[],[],iter,fscale,sizes,options);


    grad_old=grad;JacCeqTrans_old=JacCeqTrans;JacCineqTrans_old=JacCineqTrans;

    fvalTrial=fval;cIneqTrial_all=cIneq_all;cEqTrial_all=cEq_all;


    penaltyUpdateVals.initFval=fval;
    penaltyUpdateVals.initCineqViol=norm(cIneq_all(cIneq_all<0),1);
    penaltyUpdateVals.initCeqViol=norm(cEq_all,1);
    penaltyUpdateVals.threshold=1e-4;
    penaltyUpdateVals.nPenaltyDecreases=0;


    if verbosity>=3||haveoutputfcn||haveplotfcn
        if strcmpi(options.ScaleProblem,'obj-and-constr')
            objScalingFactor=fscale.obj;
        else
            objScalingFactor=1.0;
        end
    end







    if haveoutputfcn||haveplotfcn
        fvalDisp=fval/objScalingFactor;
        [optimValues,stop]=callOutputAndPlotFcns(outputfcn,plotfcns,xCurrent,...
        sizes,'init',iter,funcCount,fvalDisp,nlpPrimalFeasError,steplength,...
        searchDirection,grad,max(nlpDualFeasError,nlpComplemError),varargin{:});
        if stop
            [xCurrent,fval,lambda,exitflag,output,grad,Hess]=...
            cleanUpInterrupt(xCurrent,optimValues,sizes,makeExitMsg,verbosity);
            return;
        end

        [optimValues,stop]=callOutputAndPlotFcns(outputfcn,plotfcns,xCurrent,...
        sizes,'iter',iter,funcCount,fvalDisp,nlpPrimalFeasError,steplength,...
        searchDirection,grad,max(nlpDualFeasError,nlpComplemError),varargin{:});
        if stop
            [xCurrent,fval,lambda,exitflag,output,grad,Hess]=...
            cleanUpInterrupt(xCurrent,optimValues,sizes,makeExitMsg,verbosity);
            return;
        end
    end


    if verbosity>=4
        displayProblemInfo(sizes);
    end


    if verbosity>=3

        displayHeader(verbosity);
        fvalDisp=fval/objScalingFactor;
        fprintf('%5.0f       %5.0f  %14.6e  %10.3e                           %10.3e\n',...
        iter,funcCount,fvalDisp,nlpPrimalFeasError,max(nlpDualFeasError,nlpComplemError))
    end





    if~done
        iter=iter+1;
    end



    cleanup=onCleanup(@activesetnlp);


    while~done

        while~(stepFlags.successfulStep||stepFlags.failedLnSrch)
            evalGrads=false;
            stepFlags.qpinfeas=false;
            [searchDirection,socDirection,delta_x,lambdaqp,Weq,Wineq,Wlower,Wupper,stepFlags,penaltyParam,phiInitial,...
            phiPrimeInitial,penaltyUpdateVals,Hess,linearizedConstrViol]=computeSearchDirSQP(Hess,grad_old,fvalTrial,JacCineqTrans_old,cIneqTrial_all,...
            JacCeqTrans_old,cEqTrial_all,lb,ub,xCurrent,Weq,Wineq,Wlower,Wupper,qpoptions,searchDirection,socDirection,delta_x,...
            penaltyParam,lambda,lambdaqp,stepFlags,phiInitial,phiPrimeInitial,penaltyUpdateVals,iter,sizes,linearizedConstrViol);



            if~stepFlags.socRejected

                [fvalTrial,grad,cIneqTrial_all,cEqTrial_all,JacCineqTransUser,JacCeqTransUser,faultTolStruct,cIneqUser,cEqUser]=...
                evalObjAndConstr(funfcn,confcn,xCurrent+delta_x(:),fscale,fvalTrial,grad,cIneqTrial_all,cEqTrial_all,...
                Aeq,beq,Aineq,bineq,JacCeqTransUser,JacCineqTransUser,evalGrads,options,sizes,verbosity,varargin{:});
                funcCount=funcCount+1;


                phiFullStep=meritFcnL1(faultTolStruct.funcEvalWellDefined,penaltyParam,fvalTrial,cEqTrial_all,cIneqTrial_all);
            end

            if~(stepFlags.relaxedStep||stepFlags.socStep||stepFlags.socRejected)&&faultTolStruct.funcEvalWellDefined&&...
                (phiInitial<phiFullStep&&fvalTrial<fval)

                stepFlags.socStep=true;
            else

                [steplength,fvalTrial,grad,cEqTrial_all,cIneqTrial_all,cIneqUser,cEqUser,JacCeqTransUser,JacCineqTransUser,...
                exitflagLnSrch,funcCount,faultTolStruct]=backtrackLineSearch(funfcn,confcn,penaltyParam,...
                xCurrent,searchDirection,socDirection,stepFlags,faultTolStruct,phiInitial,phiPrimeInitial,...
                phiFullStep,fvalTrial,grad,cEqTrial_all,cIneqTrial_all,cIneqUser,cEqUser,JacCeqTransUser,...
                JacCineqTransUser,Aineq,bineq,Aeq,beq,funcCount,fscale,sizes,options,verbosity,varargin{:});

                delta_x=steplength*searchDirection;
                if stepFlags.socStep
                    delta_x=delta_x+steplength^2*socDirection;
                end



                if exitflagLnSrch>0
                    stepFlags.successfulStep=true;
                else
                    stepFlags.failedLnSrch=true;
                end
            end
        end

        if stepFlags.successfulStep

            xCurrent=xCurrent+delta_x;


            lambda=lambda+steplength*(lambdaqp(xIndices.lambdaIdx)-lambda);

            fval=fvalTrial;
            cEq_all=cEqTrial_all;
            cIneq_all=cIneqTrial_all;



            [grad,JacCineqTransUser,JacCeqTransUser,extraEvals,evalOK]=...
            computeFinDiffGradAndJac(xCurrent,funfcn,confcn,fval,-cIneqUser,cEqUser,grad,...
            JacCineqTransUser,JacCeqTransUser,lb,ub,fscale,options,finDiffFlags,sizes,varargin{:});
            funcCount=funcCount+extraEvals;



            undefGrads=~evalOK;

            if strcmp(funfcn{1},'fungrad')||strcmp(funfcn{1},'fun_then_grad')||...
                strcmp(confcn{1},'fungrad')||strcmp(confcn{1},'fun_then_grad')

                evalGrads=true;
                [fval,grad,cIneq_all,cEq_all,JacCineqTransUser,JacCeqTransUser]=...
                evalObjAndConstr(funfcn,confcn,xCurrent,fscale,fval,grad,cIneq_all,cEq_all,Aeq,beq,...
                Aineq,bineq,JacCeqTransUser,JacCineqTransUser,evalGrads,options,sizes,verbosity,varargin{:});


                if strcmp(funfcn{1},'fungrad')
                    funcCount=funcCount+1;
                end
            end

            JacCineqTransUser=-JacCineqTransUser;


            JacCeqTrans=[Aeq',JacCeqTransUser];
            JacCineqTrans=[Aineq',JacCineqTransUser];
        else


            fvalTrial=fval;
            cEqTrial_all=cEq_all;
            cIneqTrial_all=cIneq_all;
        end



        [done,exitflag,msgData,nlpPrimalFeasError,nlpDualFeasError,nlpComplemError,lambdaStopTest,stepFlags]=...
        stopTestSQP(xCurrent,lambda,lambdaStopTest,fval,grad,cEq_all,JacCeqTrans,cIneq_all,JacCineqTrans,...
        lb,ub,feasRelativeFactor,delta_x,iter,funcCount,Weq,Wineq,Wlower,Wupper,verbosity,fscale,sizes,...
        xIndices,stepFlags,undefGrads,options,detailedExitMsg);
        KKT_error=max([nlpDualFeasError,nlpComplemError]);







        if(~done&&stepFlags.successfulStep)||done

            if verbosity>=3
                if faultTolStruct.undefObj
                    fprintf(getString(message('optimlib:commonMsgs:ObjInfNaNComplex',...
                    faultTolStruct.undefValue)));
                elseif faultTolStruct.undefConstr
                    fprintf(getString(message('optimlib:commonMsgs:ConstrInfNaNComplex',...
                    faultTolStruct.undefValue)));
                end

                faultTolStruct.undefConstr=false;
                faultTolStruct.undefObj=false;




                if mod(iter-1,30)==0&&iter>1
                    fprintf('\n');
                    displayHeader(verbosity);
                end

                fvalDisp=fval/objScalingFactor;
                fprintf('%5.0f       %5.0f  %14.6e  %10.3e   %10.3e  %10.3e  %10.3e',...
                iter,funcCount,fvalDisp,nlpPrimalFeasError,steplength,norm(delta_x),...
                max(nlpDualFeasError,nlpComplemError))
                if verbosity>=4
                    displayTestingInfo(stepFlags,penaltyParam)
                end
                fprintf('\n');
            end

            if haveoutputfcn||haveplotfcn
                fvalDisp=fval/objScalingFactor;
                [optimValues,stop]=callOutputAndPlotFcns(outputfcn,plotfcns,xCurrent,...
                sizes,'iter',iter,funcCount,fvalDisp,nlpPrimalFeasError,steplength,...
                searchDirection,grad,max(nlpDualFeasError,nlpComplemError),varargin{:});
                if stop
                    [xCurrent,fval,lambda,exitflag,output,grad,Hess]=...
                    cleanUpInterrupt(xCurrent,optimValues,sizes,makeExitMsg,verbosity);
                    return;
                end
            end
        end
        if~done&&stepFlags.successfulStep


            stepFlags.successfulStep=false;
            stepFlags.relaxedStep=false;
            stepFlags.socStep=false;
            stepFlags.failedLnSrch=false;





            delta_gradLag=grad-grad_old...
            -(JacCeqTrans-JacCeqTrans_old)*lambda(1:nonlinEq_end,1)...
            -(JacCineqTrans-JacCineqTrans_old)*lambda(ineq_start:finiteLb_start-1,1);


            grad_old=grad;JacCeqTrans_old=JacCeqTrans;JacCineqTrans_old=JacCineqTrans;


            Hess=computeHessian([],[],[],delta_x,delta_gradLag,Hess,...
            [],[],[],[],[],[],[],[],iter,[],sizes,options);
            iter=iter+1;
        end
    end

    if haveoutputfcn||haveplotfcn
        fvalDisp=fval/objScalingFactor;
        callOutputAndPlotFcns(outputfcn,plotfcns,xCurrent,sizes,'done',iter,...
        funcCount,fvalDisp,nlpPrimalFeasError,steplength,searchDirection,...
        grad,max(nlpDualFeasError,nlpComplemError),varargin{:});
    end


    if strcmpi(options.ScaleProblem,'obj-and-constr')
        fval=fval/fscale.obj;
        grad=grad/fscale.obj;
        if~isempty(Hess)
            Hess=Hess/fscale.obj;
        end
        lambdaStopTest=(fscale.constr.*lambdaStopTest)/fscale.obj;
    end

    xCurrent=reshape(xCurrent,sizes.xShape);
    lambda=formLambdaStruct(lambdaStopTest,grad,xIndices,sizes,true);
    output.iterations=iter;
    output.funcCount=funcCount;
    output.algorithm='sqp-legacy';

    if makeExitMsg
        output.message=createExitMsg(msgData{:});
    end
    output.constrviolation=nlpPrimalFeasError;
    output.stepsize=norm(delta_x,2);
    output.lssteplength=steplength;
    output.firstorderopt=KKT_error;


    function displayHeader(verbosity)


        fprintf('                                                               Norm of First-order\n')
        fprintf(' Iter  Func-count            Fval Feasibility  Step Length        step  optimality')
        if verbosity>=4
            fprintf('    Pen-Param');
        end
        fprintf('\n');


        function displayTestingInfo(stepFlags,penaltyParam)


            if stepFlags.relaxedStep
                if stepFlags.qpinfeas
                    stepType='relaxed(infeas)';
                else
                    stepType='relaxed(l-s failed)';
                end
            else
                if stepFlags.socStep
                    stepType='SOC';
                else
                    stepType='';
                end
            end
            fprintf('   %10.3e %s',max(penaltyParam),stepType);


            function[optimValues,stop]=callOutputAndPlotFcns(outputfcn,plotfcns,xCurrent,sizes,...
                state,iter,funcCount,fval,nlpPrimalFeasError,steplength,searchDirection,grad,...
                optimError,varargin)








                optimValues.iteration=iter;
                optimValues.funccount=funcCount;
                optimValues.fval=fval;
                optimValues.constrviolation=nlpPrimalFeasError;
                optimValues.lssteplength=steplength;
                optimValues.searchdirection=searchDirection;
                optimValues.gradient=grad;
                optimValues.firstorderopt=optimError;
                optimValues.procedure='';
                optimValues.stepsize=[];
                if~isempty(searchDirection)&&~isempty(steplength)
                    optimValues.stepsize=steplength*norm(searchDirection);
                end

                stop=false;
                if~isempty(outputfcn)
                    switch state
                    case{'iter','init','interrupt'}
                        stop=callAllOptimOutputFcns(outputfcn,reshape(xCurrent,sizes.xShape),...
                        optimValues,state,varargin{:})||stop;
                    case 'done'
                        callAllOptimOutputFcns(outputfcn,reshape(xCurrent,sizes.xShape),...
                        optimValues,state,varargin{:});
                    otherwise
                        error('optim:sqpLineSearch:UnknownStateInCALLOUTPUTANDPLOTFCNS',...
                        getString(message('optimlib:sqpLineSearch:UnknownStateInCALLOUTPUTANDPLOTFCNS')));
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
                    otherwise
                        error('optim:sqpLineSearch:UnknownStateInCALLOUTPUTANDPLOTFCNS',...
                        getString(message('optimlib:sqpLineSearch:UnknownStateInCALLOUTPUTANDPLOTFCNS')));
                    end
                end

                function[xCurrent,fval,lambda,exitflag,output,grad,Hess]=cleanUpInterrupt(...
                    xCurrent,optimValues,sizes,makeExitMsg,verbosity)








                    callAllOptimPlotFcns('cleanuponstopsignal');

                    xCurrent=reshape(xCurrent,sizes.xShape);

                    fval=optimValues.fval;
                    exitflag=-1;
                    output.iterations=optimValues.iteration;
                    output.funcCount=optimValues.funccount;
                    output.stepsize=optimValues.stepsize;
                    output.lssteplength=optimValues.lssteplength;
                    output.algorithm='sqp-legacy';
                    output.firstorderopt=optimValues.firstorderopt;
                    output.constrviolation=optimValues.constrviolation;

                    if makeExitMsg
                        output.message=createExitMsg({'optimlib:commonMsgs:ExitNeg1basic','fmincon'},{},verbosity>=1,false);
                    end
                    grad=optimValues.gradient;
                    Hess=[];
                    lambda=[];


                    function[lambda,lambdaStopTest,lambdaqp,Weq,Wineq,Wlower,Wupper,steplength,iter,funcCount,...
                        penaltyParam,phiInitial,phiPrimeInitial,searchDirection,socDirection,delta_x,...
                        finDiffFlags,stepFlags,qpoptions,linearizedConstrViol]=initializeSQPparam(sizes,finDiffFlags,options)

                        Weq=[];Wineq=[];Wlower=[];Wupper=[];


                        iter=0;
                        funcCount=1;
                        steplength=1;
                        lambda=zeros(sizes.mAll+sizes.mBnd,1);
                        lambdaStopTest=lambda;
                        lambdaqp=lambda;
                        penaltyParam=1;
                        socDirection=zeros(sizes.nVar,1);
                        searchDirection=zeros(sizes.nVar,1);
                        delta_x=searchDirection;
                        phiInitial=0;
                        phiPrimeInitial=0;


                        stepFlags.successfulStep=false;
                        stepFlags.relaxedStep=false;
                        stepFlags.socStep=false;
                        stepFlags.failedLnSrch=false;
                        stepFlags.socRejected=false;


                        finDiffFlags.chkFunEval=true;
                        finDiffFlags.chkComplexObj=true;


                        qpoptions.Display='off';
                        qpoptions.MaxIter=10*max(sizes.nVar,sizes.mIneq+sizes.mBnd);
                        qpoptions.TolFun=100*eps;
                        qpoptions.TolX=1e-6;
                        qpoptions.TolCon=options.TolCon;

                        linearizedConstrViol=0;
