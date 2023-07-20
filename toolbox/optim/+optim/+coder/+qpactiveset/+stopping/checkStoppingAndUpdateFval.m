function[activeSetChangeID,solution,memspace,objective,workingset,qrmanager]=...
    checkStoppingAndUpdateFval(activeSetChangeID,H,f,solution,...
    memspace,objective,workingset,qrmanager,...
    options,runTimeOptions,updateFval)










%#codegen

    coder.allowpcode('plain');

    validateattributes(activeSetChangeID,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(H,{'double'},{'2d'});
    validateattributes(f,{'double'},{'2d'});
    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(objective,{'struct'},{'scalar'});
    validateattributes(workingset,{'struct'},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});
    validateattributes(options,{'struct'},{'scalar'});
    validateattributes(runTimeOptions,{'struct'},{'scalar'});
    validateattributes(updateFval,{'logical'},{'scalar'});

    coder.internal.prefer_const(H,f,options);

    solution.iterations=solution.iterations+1;
    nVar=objective.nvar;

    PHASE_ONE=coder.const(optim.coder.qpactiveset.Objective.ID('PHASEONE'));
    MAX_ITER_REACHED=coder.const(optim.coder.SolutionState('MaxIterReached'));
    OPTIMAL=coder.const(optim.coder.SolutionState('Optimal'));


    [objType,objective]=optim.coder.qpactiveset.Objective.getObjectiveType(objective);

    if(solution.iterations>=runTimeOptions.MaxIterations&&...
        ~(solution.state==OPTIMAL&&objType~=PHASE_ONE))
        solution.state=MAX_ITER_REACHED;
    end



    resetIter=coder.internal.indexInt(50);
    if(mod(solution.iterations,resetIter)==INT_ZERO)




        [solution.maxConstr,workingset]=optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(workingset,solution.xstar,INT_ONE);


        tempMaxConstr=solution.maxConstr;

        if(objType==PHASE_ONE)
            tempMaxConstr=tempMaxConstr-solution.xstar(nVar);
        end
        if(tempMaxConstr>options.ConstraintTolerance*runTimeOptions.ConstrRelTolFactor)



            solution.searchDir=coder.internal.blas.xcopy(nVar,solution.xstar,INT_ONE,INT_ONE,solution.searchDir,INT_ONE,INT_ONE);
            [solution.searchDir,nonDegenerateWset,memspace.workspace_double,workingset,qrmanager]=...
            optim.coder.qpactiveset.initialize.feasibleX0ForWorkingSet(memspace.workspace_double,solution.searchDir,workingset,qrmanager);

            if(~nonDegenerateWset&&solution.state~=MAX_ITER_REACHED)
                solution.state=coder.const(optim.coder.SolutionState('Infeasible'));
            end

            activeSetChangeID=INITIAL_SET;
            [constrViolation_new,workingset]=optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(workingset,solution.searchDir,INT_ONE);



            if(constrViolation_new<solution.maxConstr)
                for idx=INT_ONE:nVar
                    solution.xstar(idx)=solution.searchDir(idx);
                end
                solution.maxConstr=constrViolation_new;
            else

            end
        end
    end


    if updateFval



        if(~eml_option('NonFinitesSupport')||options.ObjectiveLimit>-coder.internal.inf)||options.IterDisplayQP
            [solution.fstar,memspace.workspace_double,objective]=...
            optim.coder.qpactiveset.Objective.computeFval_ReuseHx(objective,...
            memspace.workspace_double,H,f,solution.xstar);



            if(~eml_option('NonFinitesSupport')||options.ObjectiveLimit>-coder.internal.inf)&&...
                (solution.fstar<options.ObjectiveLimit&&...
                ~(solution.state==MAX_ITER_REACHED&&objType==PHASE_ONE))
                solution.state=coder.const(optim.coder.SolutionState('ObjectiveLimitReached'));
            end
        end
    end
end



function formulaType=INITIAL_SET
    coder.inline('always');
    formulaType=coder.internal.indexInt(0);
end


function formulaType=INT_ONE
    coder.inline('always');
    formulaType=coder.internal.indexInt(1);
end

function formulaType=INT_ZERO
    coder.inline('always');
    formulaType=coder.internal.indexInt(0);
end