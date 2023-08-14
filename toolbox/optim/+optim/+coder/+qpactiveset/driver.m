function[solution,memspace,workingset,qrmanager,cholmanager,objective]=...
    driver(H,f,solution,memspace,workingset,qrmanager,cholmanager,objective,options,runTimeOptions)























































%#codegen

    coder.allowpcode('plain');

    validateattributes(H,{'double'},{'2d','square','nonempty'});
    validateattributes(f,{'double'},{'2d'});
    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(workingset,{'struct'},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});
    validateattributes(cholmanager,{'struct'},{'scalar'});
    validateattributes(objective,{'struct'},{'scalar'});
    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(runTimeOptions,{'struct'},{'scalar'});

    coder.internal.prefer_const(H,f,options);

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    NORMAL=coder.const(optim.coder.qpactiveset.constants.ConstraintType('NORMAL'));


    solution.iterations=INT_ZERO;



    runTimeOptions.RemainFeasible=(options.PricingTolerance<=0.0);

    nVar=coder.internal.indexInt(workingset.nVar);



    if strcmpi(options.SolverName,'quadprog')||strcmpi(options.SolverName,'lsqlin')||...
        (workingset.probType==NORMAL)

        solution=optim.coder.qpactiveset.snap_bounds(solution,workingset);

        [solution,memspace,workingset,qrmanager,options]=...
        optim.coder.qpactiveset.initialize.PresolveWorkingSet(solution,memspace,workingset,qrmanager,options);


        if(solution.state<INT_ZERO)
            return;
        end
    else


        solution.state=coder.const(optim.coder.SolutionState('PrimalFeasible'));
    end


    solution.iterations=INT_ZERO;



    [solution.maxConstr,workingset]=optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(workingset,solution.xstar,INT_ONE);

    if(solution.maxConstr>options.ConstraintTolerance*runTimeOptions.ConstrRelTolFactor)


        [solution,memspace,workingset,qrmanager,cholmanager,objective,options,runTimeOptions]=...
        optim.coder.qpactiveset.phaseone(H,f,solution,memspace,...
        workingset,qrmanager,cholmanager,objective,options,runTimeOptions);

        if(solution.state==coder.const(optim.coder.SolutionState('MaxIterReached')))
            return;
        end





        [solution.maxConstr,workingset]=optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(workingset,solution.xstar,INT_ONE);

        if(solution.maxConstr>options.ConstraintTolerance*runTimeOptions.ConstrRelTolFactor)

            solution.lambda=coder.internal.blas.xcopy(workingset.mConstrMax,0.0,INT_ONE,INT_ZERO,solution.lambda,INT_ONE,INT_ONE);

            [solution.fstar,memspace.workspace_double,objective]=...
            optim.coder.qpactiveset.Objective.computeFval(objective,memspace.workspace_double,H,f,solution.xstar);

            solution.state=coder.const(optim.coder.SolutionState('Infeasible'));
            return;
        elseif(solution.maxConstr>0.0)







            solution.searchDir=coder.internal.blas.xcopy(nVar,...
            solution.xstar,INT_ONE,INT_ONE,solution.searchDir,INT_ONE,INT_ONE);

            [solution,memspace,workingset,qrmanager,options]=...
            optim.coder.qpactiveset.initialize.PresolveWorkingSet(solution,memspace,workingset,qrmanager,options);

            [maxConstr_new,workingset]=optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(workingset,solution.xstar,INT_ONE);



            if(maxConstr_new>=solution.maxConstr)
                solution.maxConstr=maxConstr_new;
                solution.xstar=coder.internal.blas.xcopy(nVar,...
                solution.searchDir,INT_ONE,INT_ONE,solution.xstar,INT_ONE,INT_ONE);
            end
        end
    end


    [solution,memspace,workingset,qrmanager,cholmanager,objective]=...
    optim.coder.qpactiveset.iterate(H,f,solution,memspace,workingset,...
    qrmanager,cholmanager,objective,options,runTimeOptions);

    if~(strcmpi(options.SolverName,'quadprog')||strcmpi(options.SolverName,'lsqlin'))

        return;
    end

    if(solution.state==coder.const(optim.coder.SolutionState('IndefiniteQP')))
        return;
    end


    [solution.maxConstr,workingset]=optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(workingset,solution.xstar,INT_ONE);
    [solution,objective,memspace.workspace_double]=...
    optim.coder.qpactiveset.parseoutput.computeFirstOrderOpt(solution,objective,workingset,...
    memspace.workspace_double);





    DEGENERATE_CONSTR=coder.const(optim.coder.SolutionState('DegenerateConstraints'));
    OPTIMAL=coder.const(optim.coder.SolutionState('Optimal'));
    runTimeOptions.RemainFeasible=false;
    while(solution.iterations<runTimeOptions.MaxIterations&&(solution.state==DEGENERATE_CONSTR||...
        (solution.state==OPTIMAL&&(solution.maxConstr>options.ConstraintTolerance*runTimeOptions.ConstrRelTolFactor||...
        solution.firstorderopt>options.OptimalityTolerance*runTimeOptions.ProbRelTolFactor))))


        [solution.xstar,~,memspace.workspace_double,workingset,qrmanager]=...
        optim.coder.qpactiveset.initialize.feasibleX0ForWorkingSet(memspace.workspace_double,solution.xstar,workingset,qrmanager);


        [solution,memspace,workingset,qrmanager,options]=...
        optim.coder.qpactiveset.initialize.PresolveWorkingSet...
        (solution,memspace,workingset,qrmanager,options);


        [solution,memspace,workingset,qrmanager,cholmanager,objective,options,runTimeOptions]=...
        optim.coder.qpactiveset.phaseone(H,f,solution,memspace,...
        workingset,qrmanager,cholmanager,objective,options,runTimeOptions);


        [solution,memspace,workingset,qrmanager,cholmanager,objective]=...
        optim.coder.qpactiveset.iterate(H,f,solution,memspace,workingset,...
        qrmanager,cholmanager,objective,options,runTimeOptions);

        [solution.maxConstr,workingset]=optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(workingset,solution.xstar,INT_ONE);
        [solution,objective,memspace.workspace_double]=...
        optim.coder.qpactiveset.parseoutput.computeFirstOrderOpt(solution,objective,workingset,...
        memspace.workspace_double);
    end

end


