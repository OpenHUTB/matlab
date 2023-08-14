function[wsol,wsolCauchy,numFunEvals,iter,projCGIterRef,solType]=...
    projConjGrad(Hess,barrierHess_s,slacks,residual,AugFactor,trRadius_tang,...
    JacTrans_ip,absTol,relTol,maxIter,funfcn,confcn,fscale,xCurrent,grad,...
    lb,ub,xIndices,lambda_ip,constrGradNorms_ip,options,sizes,varargin)























    nVar=sizes.nVar;
    nPrimal=sizes.nPrimal;
    nonlinEq_start=sizes.nonlinEq_start;
    nonlinEq_end=sizes.nonlinEq_end;
    nonlinIneq_start=sizes.nonlinIneq_start;

    wsol=zeros(nPrimal,1);
    wsolCauchy=wsol;

    [projResidual,numIterRef]=computeProjResidual(AugFactor,residual,...
    slacks,JacTrans_ip,constrGradNorms_ip,sizes);

    dir=projResidual;
    resProjRes=residual'*projResidual;
    resProjRes=max(resProjRes,0.0);
    normProjRes=sqrt(resProjRes);

    iter=0;projCGIterRef=numIterRef;
    solType='residual';

    numFunEvals=0;
    while sqrt(resProjRes)>=max(relTol*normProjRes,absTol)&&...
        iter<=maxIter
        iter=iter+1;


        [hessianVector,evalCount]=hessTimesVector(Hess,dir(1:nVar),funfcn,confcn,xCurrent,...
        grad,JacTrans_ip(1:nVar,nonlinEq_start:nonlinEq_end),...
        JacTrans_ip(1:nVar,nonlinIneq_start:end),lb,ub,xIndices,fscale,lambda_ip,...
        options,sizes,varargin{:});
        numFunEvals=numFunEvals+evalCount;


        curvature=dir(1:nVar)'*hessianVector+...
        sum((dir(nVar+1:nPrimal,1).^2).*barrierHess_s);
        if curvature<=0.0
            tau=stplngthToTrBoundary(wsol,dir,trRadius_tang);
            wsol=wsol+tau*dir;
            if iter==1
                wsolCauchy=wsol;
            end
            solType='negcurv';
            break
        end
        alpha=resProjRes/curvature;



        if norm(wsol+alpha*dir)>=trRadius_tang
            tau=stplngthToTrBoundary(wsol,dir,trRadius_tang);
            wsol=wsol+tau*dir;
            if iter==1
                wsolCauchy=wsol;
            end
            solType='trbndry';
            break
        end

        wsol=wsol+alpha*dir;
        if iter==1
            wsolCauchy=wsol;
        end
        resProjRes_old=resProjRes;
        residual=residual-alpha*[hessianVector;
        barrierHess_s.*dir(nVar+1:nPrimal,1)];

        [projResidual,numIterRef]=computeProjResidual(AugFactor,residual,...
        slacks,JacTrans_ip,constrGradNorms_ip,sizes);
        projCGIterRef=projCGIterRef+numIterRef;


        residual=projResidual;
        resProjRes=residual'*projResidual;
        beta=resProjRes/resProjRes_old;
        dir=projResidual+beta*dir;
    end


    function tau=stplngthToTrBoundary(wsol,dir,trRadius)



        wsoldir=wsol'*dir;
        dir2=dir'*dir;
        wsol2=wsol'*wsol;
        trRadius2=trRadius^2;


        rootArg=wsoldir^2+dir2*trRadius2-dir2*wsol2;
        rootArg=max(rootArg,0.0);

        if dir2<=0

            tau=0.0;
        else





            tau1=-(wsoldir+(sign(wsoldir)+(wsoldir==0))*sqrt(rootArg))/dir2;

            if tau1>=0
                tau=tau1;
            else
                tau=(wsol2-trRadius2)/(dir2*tau1);
            end
        end


        function[projResidual,numIterRef]=computeProjResidual(AugFactor,residual,...
            slacks,JacTrans_ip,constrGradNorms_ip,sizes)




            nVar=sizes.nVar;nPrimal=sizes.nPrimal;
            mEq=sizes.mEq;mIneq=sizes.mIneq;

            numIterRef=0;

            [projResidual,solLower]=solveAugSystem(AugFactor,residual(1:nVar),...
            residual(nVar+1:nPrimal,1),zeros(mEq,1),zeros(mIneq,1),slacks,sizes);

            [absCosAngle,JacTimesProjResidual]=getProjectionAngle(projResidual,JacTrans_ip,constrGradNorms_ip);


            while absCosAngle>100*eps&&numIterRef<6
                rhsUpper=residual-projResidual-JacTrans_ip*solLower;
                rhsLower=-JacTimesProjResidual;
                [deltaProjResidual,deltaSolLower]=solveAugSystem(AugFactor,rhsUpper(1:nVar),...
                rhsUpper(nVar+1:nPrimal,1),rhsLower(1:mEq,1),rhsLower(mEq+1:mEq+mIneq,1),slacks,...
                sizes);
                projResidual=projResidual+deltaProjResidual;
                solLower=solLower+deltaSolLower;
                numIterRef=numIterRef+1;
                [absCosAngle,JacTimesProjResidual]=getProjectionAngle(projResidual,JacTrans_ip,constrGradNorms_ip);
            end


            function[absCosAngle,JacTimesProjResidual]=getProjectionAngle(projResidual,JacTrans_ip,constrGradNorms_ip)



                normProjResidual=norm(projResidual);
                JacTimesProjResidual=JacTrans_ip'*projResidual;
                if normProjResidual>0

                    absCosAngle=norm(JacTimesProjResidual./max(eps,constrGradNorms_ip),inf);
                    absCosAngle=absCosAngle/normProjResidual;
                else
                    absCosAngle=0;
                end

