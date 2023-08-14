function[alpha,newBlocking,constrType,constrIdx,workspace,toldelta]=...
    ratiotest(solution,workspace,workingset,isPhaseOne,tolcon,toldelta,toltau)














































%#codegen

    coder.allowpcode('plain');



    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(workspace,{'double'},{'2d'});
    validateattributes(workingset,{'struct'},{'scalar'});
    validateattributes(isPhaseOne,{'logical'},{'scalar'});
    validateattributes(tolcon,{'double'},{'scalar'});
    validateattributes(toldelta,{'double'},{'scalar'});
    validateattributes(toltau,{'double'},{'scalar'});


    ERRNORM=coder.const(optim.coder.qpactiveset.constants.RatioTestTolerances('ErrNorm'));


    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));


    totalIneq=workingset.sizes(AINEQ);
    totalLB=workingset.sizes(LOWER);
    totalUB=workingset.sizes(UPPER);

    nWineq=workingset.nWConstr(AINEQ);
    nWLB=workingset.nWConstr(LOWER);
    nWUB=workingset.nWConstr(UPPER);

    nVar=workingset.nVar;


    alpha=coder.const(optim.coder.qpactiveset.constants.RatioTestTolerances('MaxStepSize'));

    newBlocking=false;
    constrType=coder.internal.indexInt(0);
    constrIdx=coder.internal.indexInt(0);

    INT_ONE=coder.internal.indexInt(1);


    p_max=0.0;



    denomTol=ERRNORM*coder.internal.blas.xnrm2(nVar,solution.searchDir,INT_ONE,INT_ONE);





    if(nWineq<totalIneq)


        workspace=coder.internal.blas.xcopy(totalIneq,workingset.bineq,INT_ONE,INT_ONE,workspace,INT_ONE,INT_ONE);


        workspace=coder.internal.blas.xgemv('T',nVar,totalIneq,1.0,workingset.Aineq,INT_ONE,workingset.ldA,solution.xstar,INT_ONE,INT_ONE,-1.0,workspace,INT_ONE,INT_ONE);


        ldw=coder.internal.indexInt(size(workspace,1));
        workspace=coder.internal.blas.xgemv('T',nVar,totalIneq,1.0,workingset.Aineq,INT_ONE,workingset.ldA,solution.searchDir,INT_ONE,INT_ONE,0.0,workspace,ldw+INT_ONE,INT_ONE);

        for idx=1:totalIneq
            if(workspace(ldw+idx)>denomTol&&~optim.coder.qpactiveset.WorkingSet.isActive(workingset,AINEQ,idx))


                alphaTemp=min(abs(workspace(idx)-toldelta),tolcon-workspace(idx)+toldelta)/workspace(ldw+idx);
                if(alphaTemp<=alpha&&abs(workspace(ldw+idx))>p_max)


                    alpha=alphaTemp;
                    constrType=AINEQ;
                    constrIdx=idx;
                    newBlocking=true;
                end


                alphaTemp=min(abs(workspace(idx)),tolcon-workspace(idx))/workspace(ldw+idx);
                if(alphaTemp<alpha)


                    alpha=alphaTemp;
                    constrType=AINEQ;
                    constrIdx=idx;
                    newBlocking=true;
                    p_max=abs(workspace(ldw+idx));
                end

            end
        end

    end












    if(nWLB<totalLB)

        nfiniteLB=coder.internal.indexInt(totalLB);
        phaseOneCorrectionX=double(isPhaseOne)*solution.xstar(nVar);
        phaseOneCorrectionP=double(isPhaseOne)*solution.searchDir(nVar);

        for idx=1:nfiniteLB-1
            idx_lb=workingset.indexLB(idx);
            pk_corrected=-solution.searchDir(idx_lb)-phaseOneCorrectionP;

            if(pk_corrected>denomTol&&~optim.coder.qpactiveset.WorkingSet.isActive(workingset,LOWER,idx))


                ratio=-solution.xstar(idx_lb)-workingset.lb(idx_lb)-toldelta-phaseOneCorrectionX;
                alphaTemp=min(abs(ratio),tolcon-ratio)/pk_corrected;

                if(alphaTemp<=alpha&&abs(pk_corrected)>p_max)


                    alpha=alphaTemp;
                    constrType=LOWER;
                    constrIdx=idx;
                    newBlocking=true;
                end


                ratio=-solution.xstar(idx_lb)-workingset.lb(idx_lb)-phaseOneCorrectionX;
                alphaTemp=min(abs(ratio),tolcon-ratio)/pk_corrected;

                if(alphaTemp<alpha)


                    alpha=alphaTemp;
                    constrType=LOWER;
                    constrIdx=idx;
                    newBlocking=true;
                    p_max=abs(pk_corrected);
                end
            end
        end




        idx_lb=workingset.indexLB(nfiniteLB);

        if(-solution.searchDir(idx_lb)>denomTol&&~optim.coder.qpactiveset.WorkingSet.isActive(workingset,LOWER,nfiniteLB))


            ratio=-solution.xstar(idx_lb)-workingset.lb(idx_lb)-toldelta;
            alphaTemp=min(abs(ratio),tolcon-ratio)/-solution.searchDir(idx_lb);

            if(alphaTemp<=alpha&&abs(solution.searchDir(idx_lb))>p_max)


                alpha=alphaTemp;
                constrType=LOWER;
                constrIdx=nfiniteLB;
                newBlocking=true;
            end


            ratio=-solution.xstar(idx_lb)-workingset.lb(idx_lb);
            alphaTemp=min(abs(ratio),tolcon-ratio)/-solution.searchDir(idx_lb);

            if(alphaTemp<alpha)


                alpha=alphaTemp;
                constrType=LOWER;
                constrIdx=nfiniteLB;
                newBlocking=true;
                p_max=abs(solution.searchDir(idx_lb));
            end

        end

    end


    if(nWUB<totalUB)

        nFiniteUB=coder.internal.indexInt(totalUB);
        phaseOneCorrectionX=double(isPhaseOne)*solution.xstar(nVar);
        phaseOneCorrectionP=double(isPhaseOne)*solution.searchDir(nVar);


        for idx=1:nFiniteUB
            idx_ub=workingset.indexUB(idx);
            pk_corrected=solution.searchDir(idx_ub)-phaseOneCorrectionP;

            if(pk_corrected>denomTol&&~optim.coder.qpactiveset.WorkingSet.isActive(workingset,UPPER,idx))


                ratio=solution.xstar(idx_ub)-workingset.ub(idx_ub)-toldelta-phaseOneCorrectionX;
                alphaTemp=min(abs(ratio),tolcon-ratio)/pk_corrected;

                if(alphaTemp<=alpha&&abs(pk_corrected)>p_max)


                    alpha=alphaTemp;
                    constrType=UPPER;
                    constrIdx=idx;
                    newBlocking=true;
                end


                ratio=solution.xstar(idx_ub)-workingset.ub(idx_ub)-phaseOneCorrectionX;
                alphaTemp=min(abs(ratio),tolcon-ratio)/pk_corrected;

                if(alphaTemp<alpha)


                    alpha=alphaTemp;
                    constrType=UPPER;
                    constrIdx=idx;
                    newBlocking=true;
                    p_max=abs(pk_corrected);
                end

            end

        end

    end


    toldelta=toldelta+toltau;


    if(p_max>0)
        alpha=max(alpha,toltau/p_max);
    end



    if isPhaseOne
        LP_MAXSTEPSIZE=coder.const(optim.coder.qpactiveset.constants.RatioTestTolerances('MaxLPStepSize'));
        if(newBlocking&&alpha>LP_MAXSTEPSIZE)
            newBlocking=false;
        end
        alpha=min(alpha,LP_MAXSTEPSIZE);
    else
        QP_MAXSTEPSIZE=coder.const(optim.coder.qpactiveset.constants.RatioTestTolerances('MaxQPStepSize'));
        if(newBlocking&&alpha>QP_MAXSTEPSIZE)
            newBlocking=false;
        end
        alpha=min(alpha,QP_MAXSTEPSIZE);
    end

end