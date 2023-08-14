function[done,exitflag,messageData,isFeasible,...
    nlpPrimalFeasError,nlpDualFeasError,nlpComplemError,...
    lambdaStopTest,lambdaStopTestPrev]=...
    nlpStopTest(xCurrent,lambda,fval,grad,JacTrans_ip,cEq_all,cIneq_all,...
    c_ip,constrGradNorms_ip,AugFactor,slacks,barrierParam,...
    delta_x,useDirect,iter,funcCount,feasRelativeFactor,...
    optimRelativeFactor,lambdaStopTestPrev,evalOK,fscale,...
    sizes,verbosity,detailedMsg,options)



















    nVar=sizes.nVar;
    mEq=sizes.mEq;
    mIneq=sizes.mIneq;


    exitflag=[];




    messageData={};


    if~strcmpi(options.ScaleProblem,'obj-and-constr')
        eqPrimalFeasError=norm(cEq_all,Inf);
        ineqPrimalFeasError=norm(max(-cIneq_all,0),inf);
    else

        eqPrimalFeasError=norm((cEq_all./fscale.constr(1:mEq,1)),Inf);
        ineqPrimalFeasError=norm(max((-cIneq_all./fscale.constr(mEq+1:end,1)),0),inf);
    end
    nlpPrimalFeasError=max(eqPrimalFeasError,ineqPrimalFeasError);



    if iter==0
        feasRelativeFactor=max(1,nlpPrimalFeasError);
    end


    if nlpPrimalFeasError<=options.TolCon*feasRelativeFactor
        isFeasible=true;
    else
        isFeasible=false;
    end





    nlpDualFeasError=norm(grad-JacTrans_ip(1:nVar,:)*lambda,inf);
    if strcmpi(options.ScaleProblem,'obj-and-constr')

        nlpDualFeasError=nlpDualFeasError/fscale.obj;
    end


    if mIneq>0
        complem=cIneq_all.*lambda(mEq+1:end,1);


        if~strcmpi(options.ScaleProblem,'obj-and-constr')
            nlpComplemError=max(min([abs(complem),abs(cIneq_all),lambda(mEq+1:end,1)],[],2));
        else
            nlpComplemError=max(min([abs(complem/fscale.obj),abs(cIneq_all./fscale.constr(mEq+1:end,1)),...
            (fscale.constr(mEq+1:end,1).*lambda(mEq+1:end,1))/fscale.obj],[],2));
        end
    else
        nlpComplemError=0;
    end

    if~evalOK

        done=true;



        if~useDirect


            lambdaStopTest=lambdaStopTestPrev;
        else

            lambdaStopTest=lambda;
        end
        if isFeasible
            exitflag=2;
            msgID='optimlib:sqpLineSearch:Exit26detailed';
            dispMsg=verbosity>=2;
        else
            exitflag=-2;
            msgID='optimlib:sqpLineSearch:ExitNeg26detailed';
            dispMsg=verbosity>=1;
        end
        messageData={{replace(msgID,'detailed','basic'),'fmincon'},...
        {msgID,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
        dispMsg,detailedMsg};
        return
    end




    if~useDirect&&mIneq>0

        computeBarrierMults=false;
        lambdaStopTest=leastSquaresLagrangeMults(AugFactor,grad,slacks,...
        barrierParam,computeBarrierMults,sizes);

        nlpDualFeasErrorTmp=norm(grad-JacTrans_ip(1:nVar,:)*lambdaStopTest,inf);
        if strcmpi(options.ScaleProblem,'obj-and-constr')

            nlpDualFeasErrorTmp=nlpDualFeasErrorTmp/fscale.obj;
        end

        complem=cIneq_all.*lambdaStopTest(mEq+1:end,1);

        if~strcmpi(options.ScaleProblem,'obj-and-constr')
            nlpComplemErrorTmp=max(min([abs(complem),abs(cIneq_all),lambdaStopTest(mEq+1:end,1)],[],2));
        else
            nlpComplemErrorTmp=max(min([abs(complem/fscale.obj),abs(cIneq_all./fscale.constr(mEq+1:end,1)),...
            (fscale.constr(mEq+1:end,1).*lambdaStopTest(mEq+1:end,1))/fscale.obj],[],2));
        end

        if max(nlpDualFeasErrorTmp,nlpComplemErrorTmp)<max(nlpDualFeasError,nlpComplemError)

            nlpDualFeasError=nlpDualFeasErrorTmp;
            nlpComplemError=nlpComplemErrorTmp;
        else

            lambdaStopTest=lambda;
        end
    else
        lambdaStopTest=lambda;
    end







    if iter>0

        nlpDualFeasErrorTmp=norm(grad-JacTrans_ip(1:nVar,:)*lambdaStopTestPrev,inf);
        if strcmpi(options.ScaleProblem,'obj-and-constr')

            nlpDualFeasErrorTmp=nlpDualFeasErrorTmp/fscale.obj;
        end

        complem=cIneq_all.*lambdaStopTestPrev(mEq+1:end,1);

        if~strcmpi(options.ScaleProblem,'obj-and-constr')
            nlpComplemErrorTmp=max(min([abs(complem),abs(cIneq_all),lambdaStopTestPrev(mEq+1:end,1)],[],2));
        else
            nlpComplemErrorTmp=max(min([abs(complem/fscale.obj),abs(cIneq_all./fscale.constr(mEq+1:end,1)),...
            (fscale.constr(mEq+1:end,1).*lambdaStopTestPrev(mEq+1:end,1))/fscale.obj],[],2));
        end

        if max(nlpDualFeasErrorTmp,nlpComplemErrorTmp)<max(nlpDualFeasError,nlpComplemError)

            nlpDualFeasError=nlpDualFeasErrorTmp;
            nlpComplemError=nlpComplemErrorTmp;
            lambdaStopTest=lambdaStopTestPrev;
        end
    end



    nlpComplemError=full(nlpComplemError);


    lambdaStopTestPrev=lambdaStopTest;


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


        messageData={{replace(msgID,'detailed','basic')},{msgID,...
        max(nlpDualFeasError/optimRelativeFactor,nlpComplemError/optimRelativeFactor),...
        options.TolFun,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
        verbosity>=2,detailedMsg};
    else
        done=false;
    end


    if~done



        if isFeasible&&fval<options.ObjectiveLimit
            done=true;
            exitflag=-3;
            messageData={{'optimlib:sqpLineSearch:ExitNeg3basic','fmincon'},...
            {'optimlib:sqpLineSearch:ExitNeg3detailed','fmincon',...
            fval,options.ObjectiveLimit,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
            verbosity>=1,detailedMsg};





        elseif iter>0&&all(abs(delta_x)<options.TolX*max(1,abs(xCurrent)))
            done=true;
            if~isFeasible

                infeasScale=norm((1.0+constrGradNorms_ip).*c_ip,inf);
                if norm(JacTrans_ip*c_ip)<options.TolGradCon*infeasScale
                    exitflag=-2;


                    messageData={{'optim:barrier:ExitNeg21basic','fmincon'},...
                    {'optim:barrier:ExitNeg21detailed',...
                    nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
                    verbosity>=1,detailedMsg};
                else
                    exitflag=-2;

                    messageData={{'optimlib:sqpLineSearch:ExitNeg22basic','fmincon'},...
                    {'optimlib:sqpLineSearch:ExitNeg22detailed',...
                    options.TolX,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
                    verbosity>=1,detailedMsg};
                end
            else
                exitflag=2;
                messageData={{'optimlib:sqpLineSearch:Exit2basic','fmincon'},...
                {'optimlib:sqpLineSearch:Exit2detailed',...
                options.TolX,nlpPrimalFeasError/feasRelativeFactor,options.TolCon},...
                verbosity>=2,detailedMsg};
            end

        elseif iter>=options.MaxIter
            done=true;
            exitflag=0;

            messageData={{'optimlib:commonMsgs:Exit10basic','fmincon',options.MaxIter},{},verbosity>=1,false};

        elseif funcCount>=options.MaxFunEvals
            done=true;
            exitflag=0;
            messageData={{'optimlib:commonMsgs:Exit0basic','fmincon',options.MaxFunEvals},{},verbosity>=1,false};
        end
    end
