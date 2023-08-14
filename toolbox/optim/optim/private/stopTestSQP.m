function[done,exitflag,msgData,nlpPrimalFeasError,nlpDualFeasError,nlpComplemError,lambdaStopTest,stepFlags]=...
    stopTestSQP(xCurrent,lambda,lambdaStopTestPrev,fval,grad,cEq_all,JacCeqTrans,cIneq_all,JacCineqTrans,lb,ub,...
    feasRelativeFactor,delta_x,iter,funcCount,Weq,Wineq,Wlower,Wupper,verbosity,fscale,sizes,xIndices,stepFlags,...
    undefGrads,options,detailedExitMsg)



















    mEq=sizes.mEq;
    mIneq=sizes.mIneq;
    mIneqPlusBnds=mIneq+sizes.nFiniteLb+sizes.nFiniteUb;
    ineq_start=sizes.ineq_start;


    exitflag=[];msgData={};



    cIneqWithBnds=[cIneq_all
    xCurrent(xIndices.finiteLb)-lb(xIndices.finiteLb)
    ub(xIndices.finiteUb)-xCurrent(xIndices.finiteUb)];


    if strcmpi(options.ScaleProblem,'obj-and-constr')


        optimRelativeFactor=max(1,norm(grad/fscale.obj,inf));
        eqFeasError=norm((cEq_all./fscale.constr(1:mEq,1)),Inf);
        ineqFeasError=norm(max((-cIneqWithBnds./fscale.constr(ineq_start:end,1)),0),Inf);
    else
        optimRelativeFactor=max(1,norm(grad,inf));
        eqFeasError=norm(cEq_all,Inf);
        ineqFeasError=norm(max(-cIneqWithBnds,0),Inf);
    end
    nlpPrimalFeasError=max(eqFeasError,ineqFeasError);





    if~isfinite(optimRelativeFactor)
        optimRelativeFactor=1;
    end

    if iter==0
        feasRelativeFactor=max(1,nlpPrimalFeasError);
    end

    if nlpPrimalFeasError<=options.TolCon*feasRelativeFactor
        isFeasible=true;
    else
        isFeasible=false;
    end

    lambdaStopTest=lambda;



    if undefGrads




        done=true;
        nlpDualFeasError=[];
        nlpComplemError=[];

        if isFeasible
            exitflag=2;
            msgID='optimlib:sqpLineSearch:Exit26detailed';
            dispMsg=verbosity>=2;
        else
            exitflag=-2;
            msgID='optimlib:sqpLineSearch:ExitNeg26detailed';
            dispMsg=verbosity>=1;
        end
        msgData={{replace(msgID,'detailed','basic'),'fmincon'},...
        {msgID,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
        dispMsg,detailedExitMsg};
        return
    end


    Identity=eye(sizes.nVar);
    JacTransWithBnds=[JacCeqTrans,JacCineqTrans,Identity(:,xIndices.finiteLb),-Identity(:,xIndices.finiteUb)];

    [nlpDualFeasError,nlpComplemError]=computeDualFeasAndComplem(lambda,grad,...
    cIneqWithBnds,JacTransWithBnds,fscale,ineq_start,mIneqPlusBnds,options);







    if iter>1

        [nlpDualFeasErrorTmp,nlpComplemErrorTmp]=computeDualFeasAndComplem(lambdaStopTestPrev,grad,...
        cIneqWithBnds,JacTransWithBnds,fscale,ineq_start,mIneqPlusBnds,options);


        if max(nlpDualFeasErrorTmp,nlpComplemErrorTmp)<max(nlpDualFeasError,nlpComplemError)

            nlpDualFeasError=nlpDualFeasErrorTmp;
            nlpComplemError=nlpComplemErrorTmp;
            lambdaStopTest=lambdaStopTestPrev;
        end
    end


    if isFeasible&&...
        nlpDualFeasError<=options.TolFun*optimRelativeFactor&&...
        nlpComplemError<=options.TolFun*optimRelativeFactor
        done=true;
        exitflag=1;


        if iter==0
            msgID='optimlib:sqpLineSearch:Exit100detailed';
        else
            msgID='optimlib:sqpLineSearch:Exit1detailed';
        end



        msgData={{replace(msgID,'detailed','basic')},{msgID,...
        max(nlpDualFeasError/optimRelativeFactor,nlpComplemError/optimRelativeFactor),...
        options.TolFun,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
        verbosity>=2,detailedExitMsg};
    else
        done=false;
    end


    if~done
        if strcmpi(options.ScaleProblem,'obj-and-constr')
            fval=fval/fscale.obj;
        end
        if isFeasible&&fval<options.ObjectiveLimit
            done=true;
            exitflag=-3;
            msgData={{'optimlib:sqpLineSearch:ExitNeg3basic','fmincon'},...
            {'optimlib:sqpLineSearch:ExitNeg3detailed','fmincon',...
            fval,options.ObjectiveLimit,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
            verbosity>=1,detailedExitMsg};





        elseif iter>0&&(all(abs(delta_x)<options.TolX*max(1,abs(xCurrent))))
            if~isFeasible
                if~stepFlags.relaxedStep



                    stepFlags.relaxedStep=true;
                    stepFlags.failedLnSrch=false;
                    stepFlags.successfulStep=false;
                else


                    done=true;
                    exitflag=-2;
                    msgData={{'optimlib:sqpLineSearch:ExitNeg22basic','fmincon'},...
                    {'optimlib:sqpLineSearch:ExitNeg22detailed',...
                    options.TolX,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
                    verbosity>=1,detailedExitMsg};
                end
            else





                WlowerIdx=false(sizes.nVar,1);
                WlowerIdx(Wlower)=true;
                Wlower=find(WlowerIdx(xIndices.finiteLb));
                WupperIdx=false(sizes.nVar,1);
                WupperIdx(Wupper)=true;
                Wupper=find(WupperIdx(xIndices.finiteUb));


                actind=[Weq;
                Wineq+sizes.mEq;
                Wlower+sizes.finiteLb_start-1;
                Wupper+sizes.finiteUb_start-1];


                if~isempty(actind)
                    lambdaLSQ=zeros(sizes.mAll+sizes.mBnd,1);
                    lambdaLSQ(actind)=JacTransWithBnds(:,actind)\grad;
                    [nlpDualFeasErrorLSQ,nlpComplemErrorLSQ]=computeDualFeasAndComplem(lambdaLSQ,grad,...
                    cIneqWithBnds,JacTransWithBnds,fscale,ineq_start,mIneqPlusBnds,options);

                    if nlpDualFeasErrorLSQ<=options.TolFun*optimRelativeFactor&&...
                        nlpComplemErrorLSQ<=options.TolFun*optimRelativeFactor
                        done=true;
                        exitflag=1;
                        msgData={{'optimlib:sqpLineSearch:Exit1basic'},...
                        {'optimlib:sqpLineSearch:Exit1detailed',...
                        max(nlpDualFeasErrorLSQ/optimRelativeFactor,nlpComplemErrorLSQ/optimRelativeFactor),...
                        options.TolFun,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
                        verbosity>=2,detailedExitMsg};

                        nlpDualFeasError=nlpDualFeasErrorLSQ;
                        nlpComplemError=nlpComplemErrorLSQ;
                        lambdaStopTest=lambdaLSQ;
                    else


                        done=true;
                        exitflag=2;
                        msgData={{'optimlib:sqpLineSearch:Exit2basic','fmincon'},...
                        {'optimlib:sqpLineSearch:Exit2detailed',...
                        options.TolX,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
                        verbosity>=2,detailedExitMsg};
                    end
                else
                    done=true;
                    exitflag=2;
                    msgData={{'optimlib:sqpLineSearch:Exit2basic','fmincon'},...
                    {'optimlib:sqpLineSearch:Exit2detailed',...
                    options.TolX,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
                    verbosity>=2,detailedExitMsg};
                end
            end

        elseif iter>=options.MaxIter
            done=true;
            exitflag=0;

            msgData={{'optimlib:commonMsgs:Exit10basic','fmincon',options.MaxIter},{},verbosity>=1,false};

        elseif funcCount>=options.MaxFunEvals
            done=true;
            exitflag=0;
            msgData={{'optimlib:commonMsgs:Exit0basic','fmincon',options.MaxFunEvals},{},verbosity>=1,false};
        end
    end


    function[dualFeasError,complemError]=computeDualFeasAndComplem(lambda,grad,cIneq,...
        JacTransWithBnds,fscale,ineq_start,mIneqPlusBnds,options)


        dualFeasError=norm(grad-JacTransWithBnds*lambda,Inf);
        if strcmpi(options.ScaleProblem,'obj-and-constr')

            dualFeasError=dualFeasError/fscale.obj;
        end
        if mIneqPlusBnds>0

            complem=cIneq.*lambda(ineq_start:end,1);
            if strcmpi(options.ScaleProblem,'obj-and-constr')

                complemError=max(min([abs(complem/fscale.obj),abs(cIneq./fscale.constr(ineq_start:end,1)),...
                (fscale.constr(ineq_start:end,1).*lambda(ineq_start:end,1))/fscale.obj],[],2));
            else
                complemError=max(min([abs(complem),abs(cIneq),lambda(ineq_start:end)],[],2));
            end
        else
            complemError=0.0;
        end
