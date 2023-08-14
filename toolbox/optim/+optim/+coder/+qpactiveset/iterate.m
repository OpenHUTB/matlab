function[solution,memspace,workingset,qrmanager,cholmanager,objective]=...
    iterate(H,f,solution,memspace,workingset,qrmanager,cholmanager,objective,options,runTimeOptions)









































%#codegen

    coder.allowpcode('plain');

    validateattributes(H,{'double'},{'2d'});
    validateattributes(f,{'double'},{'2d'});
    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(workingset,{'struct'},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});
    validateattributes(cholmanager,{'struct'},{'scalar'});
    validateattributes(objective,{'struct'},{'scalar'});
    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(runTimeOptions,{'struct'},{'scalar'});

    coder.internal.prefer_const(H,f,options,runTimeOptions);

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    CONSTR_DELETED=coder.internal.indexInt(-1);
    CONSTR_ADDED=INT_ONE;
    INITIAL_SET=INT_ZERO;

    PHASEONE=coder.const(optim.coder.qpactiveset.Objective.ID('PHASEONE'));

    subProblemChanged=true;
    updateFval=true;
    activeSetChangeID=INITIAL_SET;

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));


    [TYPE,objective]=optim.coder.qpactiveset.Objective.getObjectiveType(objective);


    tolDelta=coder.const(optim.coder.qpactiveset.constants.RatioTestTolerances('Delta0'));
    tolTau=coder.const(optim.coder.qpactiveset.constants.RatioTestTolerances('tau'));




    nVar=coder.internal.indexInt(workingset.nVar);


    activeConstrChangedType=FIXED;
    localActiveConstrIdx=coder.internal.indexInt(0);
    globalActiveConstrIdx=coder.internal.indexInt(0);


    objective=optim.coder.qpactiveset.Objective.computeGrad_StoreHx(objective,H,f,solution.xstar);
    [solution.fstar,memspace.workspace_double,objective]=...
    optim.coder.qpactiveset.Objective.computeFval_ReuseHx(objective,memspace.workspace_double,H,f,solution.xstar);



    if(solution.iterations<runTimeOptions.MaxIterations)
        solution.state=coder.const(optim.coder.SolutionState('StartContinue'));
    else
        solution.state=coder.const(optim.coder.SolutionState('MaxIterReached'));
    end


    solution.lambda=coder.internal.blas.xcopy(workingset.mConstrMax,0.0,INT_ONE,INT_ZERO,solution.lambda,INT_ONE,INT_ONE);

    if(solution.iterations==INT_ZERO&&options.IterDisplayQP)
        optim.coder.qpactiveset.display.printHeader();
        optim.coder.qpactiveset.display.printInitialInfo(workingset.probType,solution,workingset);
    end

    while(solution.state==coder.const(optim.coder.SolutionState('StartContinue')))

        newBlocking=false;
        if(subProblemChanged)

            switch activeSetChangeID
            case CONSTR_ADDED

                workingIdx=1+workingset.ldA*(workingset.nActiveConstr-1);
                qrmanager=optim.coder.QRManager.squareQ_appendCol(qrmanager,workingset.ATwset,workingIdx);
            case CONSTR_DELETED


                qrmanager=optim.coder.QRManager.deleteColMoveEnd(qrmanager,globalActiveConstrIdx);
            otherwise
                qrmanager=optim.coder.QRManager.factorQR(qrmanager,...
                workingset.ATwset,nVar,workingset.nActiveConstr,workingset.ldA);
                qrmanager=optim.coder.QRManager.computeSquareQ(qrmanager);
            end


            alwaysPositiveDef=strcmp(options.SolverName,'fmincon');
            [solution,memspace,qrmanager,cholmanager,objective]=...
            optim.coder.qpactiveset.compute_deltax(H,solution,memspace,qrmanager,cholmanager,objective,alwaysPositiveDef);


            if(solution.state~=coder.const(optim.coder.SolutionState('StartContinue')))
                return;
            end

            normDelta=coder.internal.blas.xnrm2(nVar,solution.searchDir,INT_ONE,INT_ONE);
        else

            solution.searchDir=coder.internal.blas.xcopy(nVar,0.0,INT_ONE,INT_ZERO,solution.searchDir,INT_ONE,INT_ONE);
            normDelta=0.0;
        end

        if(~subProblemChanged||normDelta<options.StepTolerance||workingset.nActiveConstr>=nVar)




            [solution,memspace.workspace_double,objective,qrmanager]=...
            optim.coder.qpactiveset.compute_lambda(H,memspace.workspace_double,solution,objective,qrmanager);






            if(solution.state~=coder.const(optim.coder.SolutionState('DegenerateConstraints'))||workingset.nActiveConstr>nVar)

                idxMinLambda=...
                optim.coder.qpactiveset.find_neg_lambda(solution,workingset,objective,memspace,...
                options,runTimeOptions,TYPE);

                if(idxMinLambda==0)


                    solution.state=coder.const(optim.coder.SolutionState('Optimal'));
                else


                    activeSetChangeID=CONSTR_DELETED;
                    globalActiveConstrIdx=idxMinLambda;
                    subProblemChanged=true;
                    activeConstrChangedType=workingset.Wid(idxMinLambda);
                    localActiveConstrIdx=workingset.Wlocalidx(idxMinLambda);
                    workingset=optim.coder.qpactiveset.WorkingSet.removeConstr(workingset,idxMinLambda);
                    solution.lambda(idxMinLambda)=0.0;
                end
            else
                idxMinLambda=workingset.nActiveConstr;
                activeSetChangeID=INITIAL_SET;
                globalActiveConstrIdx=idxMinLambda;
                subProblemChanged=true;
                activeConstrChangedType=workingset.Wid(idxMinLambda);
                localActiveConstrIdx=workingset.Wlocalidx(idxMinLambda);
                workingset=optim.coder.qpactiveset.WorkingSet.removeConstr(workingset,idxMinLambda);
                solution.lambda(idxMinLambda)=0.0;
            end

            updateFval=false;
            alpha=coder.internal.nan;

        else

            subProblemChanged=true;
            isLP=(TYPE==PHASEONE);

            if(isLP||runTimeOptions.RemainFeasible)
                [alpha,newBlocking(:),activeConstrChangedType(:),localActiveConstrIdx(:),memspace.workspace_double]=...
                optim.coder.qpactiveset.feasibleratiotest(solution,memspace.workspace_double,...
                workingset,isLP,options.ConstraintTolerance);
            else
                [alpha,newBlocking(:),activeConstrChangedType(:),localActiveConstrIdx(:),memspace.workspace_double,tolDelta]=...
                optim.coder.qpactiveset.ratiotest(solution,memspace.workspace_double,workingset,isLP,...
                options.ConstraintTolerance,tolDelta,tolTau);
            end

            if newBlocking
                switch activeConstrChangedType
                case AINEQ
                    workingset=optim.coder.qpactiveset.WorkingSet.addAineqConstr(workingset,localActiveConstrIdx);
                case LOWER
                    workingset=optim.coder.qpactiveset.WorkingSet.addLBConstr(workingset,localActiveConstrIdx);
                otherwise
                    workingset=optim.coder.qpactiveset.WorkingSet.addUBConstr(workingset,localActiveConstrIdx);
                end
                activeSetChangeID=CONSTR_ADDED;
            else

                [solution,objective]=optim.coder.qpactiveset.stopping.checkUnboundedOrIllPosed(solution,objective);
                subProblemChanged=false;
                if(workingset.nActiveConstr==INT_ZERO)


                    solution.state=coder.const(optim.coder.SolutionState('Optimal'));
                end
            end




            solution.xstar=coder.internal.blas.xaxpy(nVar,alpha,solution.searchDir,...
            INT_ONE,INT_ONE,solution.xstar,INT_ONE,INT_ONE);



            objective=optim.coder.qpactiveset.Objective.computeGrad_StoreHx(objective,H,f,solution.xstar);


            updateFval=true;
        end

        [activeSetChangeID,solution,memspace,objective,workingset,qrmanager]=...
        optim.coder.qpactiveset.stopping.checkStoppingAndUpdateFval(activeSetChangeID,H,f,solution,...
        memspace,objective,workingset,qrmanager,options,runTimeOptions,updateFval);



        if(options.IterDisplayQP)
            if(mod(solution.iterations,coder.internal.indexInt(50))==INT_ZERO)
                optim.coder.qpactiveset.display.printHeader();
            else
                [solution.maxConstr,workingset]=...
                optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(workingset,solution.xstar,INT_ONE);
            end


            [solution,objective,memspace.workspace_double]=...
            optim.coder.qpactiveset.parseoutput.computeFirstOrderOpt(solution,objective,workingset,...
            memspace.workspace_double);

            optim.coder.qpactiveset.display.printInfo...
            (newBlocking,workingset.probType,alpha,normDelta,...
            activeConstrChangedType,localActiveConstrIdx,activeSetChangeID,solution,workingset);
        end

    end



    if(~updateFval)
        [solution.fstar,memspace.workspace_double,objective]=...
        optim.coder.qpactiveset.Objective.computeFval_ReuseHx(objective,memspace.workspace_double,H,f,solution.xstar);
    end


end
