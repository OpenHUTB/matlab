function[searchDirection,socDirection,fullStep,lambdaqp,Weq,Wineq,Wlower,Wupper,stepFlags,penaltyParam,phiInitial,...
    phiPrimeInitial,penaltyUpdateVals,Hess,linearizedConstrViol]=computeSearchDirSQP(Hess,grad,fval,JacCineqTrans,cIneq,JacCeqTrans,cEq,...
    lb,ub,xCurrent,Weq,Wineq,Wlower,Wupper,qpoptions,searchDirection,socDirection,fullStep,penaltyParam,lambda,lambdaqp,...
    stepFlags,phiInitial,phiPrimeInitial,penaltyUpdateVals,iter,sizes,linearizedConstrViol)


































    stepFlags.qpinfeas=false;
    stepFlags.socRejected=false;
    solveQP=true;
    nonconvexQPflag=-6;


    while solveQP
        if~(stepFlags.relaxedStep||stepFlags.socStep)

            try
                [searchDirection,qpval,exitflagqp,lambdaqp,Weq,Wineq,Wlower,Wupper]=activesetnlp(...
                Hess,grad,-JacCineqTrans',cIneq,JacCeqTrans',-cEq,lb-xCurrent,ub-xCurrent,...
                xCurrent,Wineq,Wlower,Wupper,qpoptions.MaxIter,qpoptions.TolCon,...
                qpoptions.TolFun,qpoptions.TolX,qpoptions.Display);
            catch ME

                throwQPexception(ME)
            end

            if exitflagqp>0


                [penaltyParam,phiInitial,phiPrimeInitial,penaltyUpdateVals,linearizedConstrViol]=updatePenaltyParam(...
                penaltyParam,fval,cIneq,cEq,[],penaltyUpdateVals,iter,qpval,linearizedConstrViol);
            elseif exitflagqp<=0&&exitflagqp~=nonconvexQPflag
                stepFlags.relaxedStep=true;
                stepFlags.qpinfeas=true;
            end
        end
        if stepFlags.relaxedStep


            nVar=sizes.nVar;
            mIneq=sizes.mIneq;
            mEq=sizes.mEq;
            mAll=sizes.mAll;
            mBnd=sizes.mBnd;
            nArtificialVar=sizes.nArtificialVar;


            JacCineqTransAug=[JacCineqTrans;
            eye(mIneq);
            zeros(2*mEq,mIneq)];
            JacCeqTransAug=[JacCeqTrans;
            zeros(mIneq,mEq);
            -eye(mEq);
            eye(mEq)];


            wInit=zeros(mIneq,1);
            uInit=zeros(mEq,1);
            vInit=zeros(mEq,1);



            linearizedEqViol=JacCeqTrans'*searchDirection+cEq;
            posViol=linearizedEqViol>0;
            uInit(posViol)=linearizedEqViol(posViol);
            negViol=linearizedEqViol<0;
            vInit(negViol)=-linearizedEqViol(negViol);
            linearizedIneqViol=-(JacCineqTrans'*searchDirection+cIneq);
            wInit(linearizedIneqViol>0)=linearizedIneqViol(linearizedIneqViol>0);



            xAug=[searchDirection;wInit;uInit;vInit];
            lbAug=[lb-xCurrent;zeros(nArtificialVar,1)];
            ubAug=[ub-xCurrent;Inf(nArtificialVar,1)];
            searchDirAug=zeros(nVar+nArtificialVar,1);



            WlowerArtificialVars=find(xAug(sizes.nVar+1:end)<=qpoptions.TolCon);
            Wlower=[Wlower;sizes.nVar+WlowerArtificialVars];

            if iter==1


                gradNorm=max(1,norm(grad,Inf));
                lambda=100*gradNorm*ones(mAll+mBnd,1);
            end

            artificialVarPenalty=norm(lambda,Inf);
            gradAug=[grad;artificialVarPenalty*ones(nArtificialVar,1)];


            betaHess=sum(diag(Hess))/nVar;



            HessAug=[Hess,zeros(nVar,nArtificialVar);
            zeros(nArtificialVar,nVar),betaHess*eye(nArtificialVar)];


            qpoptions.MaxIter=qpoptions.MaxIter+nArtificialVar;



            activesetnlp;
            try
                [searchDirAug,qpval,exitflagqp,lambdaqp,Weq,Wineq,Wlower,Wupper]=activesetnlp(...
                HessAug,gradAug,-JacCineqTransAug',cIneq,JacCeqTransAug',-cEq,lbAug,ubAug,xAug,Wineq,Wlower,...
                Wupper,qpoptions.MaxIter,qpoptions.TolCon,qpoptions.TolFun,qpoptions.TolX,qpoptions.Display);
            catch ME

                throwQPexception(ME)
            end



            if exitflagqp~=nonconvexQPflag


                artificialVars=searchDirAug(nVar+1:end);
                searchDirection(:)=searchDirAug(1:nVar);


                qpval=qpval-artificialVarPenalty*sum(artificialVars)-...
                betaHess/2*(artificialVars'*artificialVars);




                [penaltyParam,phiInitial,phiPrimeInitial,penaltyUpdateVals,linearizedConstrViol]=updatePenaltyParam(...
                penaltyParam,fval,cIneq,cEq,artificialVars,penaltyUpdateVals,iter,qpval,linearizedConstrViol);




                WlowerUVW=Wlower(Wlower>nVar)-nVar;


                activeLbIdx=false(nArtificialVar,1);
                activeLbIdx(WlowerUVW)=true;


                invalidLambdaIdx=~[activeLbIdx(mIneq+1:mAll)&activeLbIdx(mAll+1:mAll+mEq);
                activeLbIdx(1:mIneq)];
                lambdaqp(invalidLambdaIdx)=0.0;

                lambdaqp(mEq+mIneq+nVar+1:mEq+mIneq+2*nVar)=lambdaqp(mEq+mIneq+nVar+nArtificialVar+1:mEq+mIneq+2*nVar+nArtificialVar);

                lambdaqp(mEq+mIneq+2*nVar+1:end)=0.0;
            end

            Wlower=Wlower(Wlower<=sizes.nFiniteLb);
        elseif stepFlags.socStep


            socRhsEq=cEq-JacCeqTrans'*searchDirection;
            socRhsIneq=cIneq-JacCineqTrans'*searchDirection;
            try
                [socDirection,~,exitflagqp,lambdaqpTrial,WeqTrial,WineqTrial,WlowerTrial,WupperTrial]=activesetnlp(...
                Hess,grad,-JacCineqTrans',socRhsIneq,JacCeqTrans',-socRhsEq,lb-xCurrent,ub-xCurrent,xCurrent,...
                Wineq,Wlower,Wupper,qpoptions.MaxIter,qpoptions.TolCon,qpoptions.TolFun,qpoptions.TolX,qpoptions.Display);
            catch ME

                throwQPexception(ME)
            end


            socDirection=socDirection-searchDirection;
            if norm(socDirection)<=2*norm(searchDirection)

                Weq=WeqTrial;
                Wineq=WineqTrial;
                Wlower=WlowerTrial;
                Wupper=WupperTrial;
                lambdaqp=lambdaqpTrial;
            else
                stepFlags.socStep=false;
                stepFlags.socRejected=true;
            end
        end


        if exitflagqp~=nonconvexQPflag
            solveQP=false;
            if~stepFlags.socRejected


                fullStep=searchDirection;
                if stepFlags.socStep
                    fullStep=fullStep+socDirection;
                end

                lbViolation=(xCurrent+fullStep)-lb;
                lbViolIdx=lbViolation<0;
                ubViolation=ub-(xCurrent+fullStep);
                ubViolIdx=ubViolation<0;
                if any(lbViolIdx|ubViolIdx)
                    searchDirection(lbViolIdx)=searchDirection(lbViolIdx)-lbViolation(lbViolIdx);
                    searchDirection(ubViolIdx)=searchDirection(ubViolIdx)+ubViolation(ubViolIdx);
                    fullStep(lbViolIdx)=fullStep(lbViolIdx)-lbViolation(lbViolIdx);
                    fullStep(ubViolIdx)=fullStep(ubViolIdx)+ubViolation(ubViolIdx);
                end



                lambdaqp(1:sizes.mEq)=-lambdaqp(1:sizes.mEq);
            end
        else



            Hess=max(eps,norm(grad,Inf)/max(1,norm(searchDirection,Inf)))*eye(sizes.nVar);
        end
    end


    function[penaltyParam,phi,phiPrimePlus,penaltyUpdateVals,linearizedConstrViol]=updatePenaltyParam(penaltyParam,fval,...
        cIneq,cEq,artificialVars,penaltyUpdateVals,iter,qpval,...
        linearizedConstrViolPrev)


        penaltyParamMin=1e-10;
        penaltyParamTrial=penaltyParam;


        violIdx=cIneq<0;
        constrViolationEq=norm(cEq,1);
        constrViolationIneq=norm(cIneq(violIdx),1);
        constrViolation=constrViolationEq+constrViolationIneq;
        linearizedConstrViol=norm(artificialVars,1);


        if fval==0


            beta=1;
        else

            beta=1.5;
        end



        constrViolDelta=constrViolation+linearizedConstrViolPrev-linearizedConstrViol;
        if constrViolDelta>eps&&qpval>0


            penaltyParamTrial=beta*qpval/constrViolDelta;
        end





        if penaltyParamTrial<penaltyParam



            phi0=meritFcnL1(true,penaltyParamTrial,penaltyUpdateVals.initFval,...
            -penaltyUpdateVals.initCeqViol,-penaltyUpdateVals.initCineqViol);
            phi=meritFcnL1(true,penaltyParamTrial,fval,-constrViolationEq,-constrViolationIneq);

            if phi0-phi>penaltyUpdateVals.nPenaltyDecreases*penaltyUpdateVals.threshold
                penaltyUpdateVals.nPenaltyDecreases=penaltyUpdateVals.nPenaltyDecreases+1;



                if 2*penaltyUpdateVals.nPenaltyDecreases>iter
                    penaltyUpdateVals.threshold=10*penaltyUpdateVals.threshold;
                end
                penaltyParam=max(penaltyParamTrial,penaltyParamMin);
            else
                phi=meritFcnL1(true,penaltyParam,fval,-constrViolationEq,-constrViolationIneq);
            end
        else
            penaltyParam=max(penaltyParamTrial,penaltyParamMin);
            phi=meritFcnL1(true,penaltyParam,fval,-constrViolationEq,-constrViolationIneq);
        end


        phiPrimePlus=min(qpval-penaltyParam*constrViolation,0);


        function throwQPexception(originalException)

            msg=sprintf('An internal error from the QP solver was caught.');
            if strcmpi(originalException.identifier,'optimlib:src:DataTypeError')


                msg=sprintf(['%s Your objective or constraint derivatives ',...
                'must be full, real, and double.'],msg);
            else

                msg=sprintf(['%s Try re-running with ',...
                'options.Algorithm = ''interior-point''.'],msg);
            end

            qpException=MException('optim:computeSearchDirSQP:ASQPerror',msg);

            qpException=addCause(qpException,originalException);
            throw(qpException);

