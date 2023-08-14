function[solution,memspace,workingset,qrmanager,options]=PresolveWorkingSet(solution,memspace,workingset,qrmanager,options)







































%#codegen

    coder.allowpcode('plain');


    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(memspace,{'struct'},{'scalar'});
    validateattributes(workingset,{'struct'},{'scalar'});
    validateattributes(qrmanager,{'struct'},{'scalar'});
    validateattributes(options,{'struct'},{'scalar'});

    solution.state=coder.const(optim.coder.SolutionState('PrimalFeasible'));
    nEqDegen=coder.internal.indexInt(0);
    tolfactor=1e2;
    INT_ONE=coder.internal.indexInt(1);





    [nEqDegen(:),memspace,workingset,qrmanager]=...
    optim.coder.qpactiveset.initialize.RemoveDependentEq_(memspace,workingset,qrmanager,tolfactor);






    okWorkingSet=(nEqDegen~=-1)&&(workingset.nActiveConstr<=qrmanager.ldq);




    if(okWorkingSet)
        [workingset,qrmanager,memspace]=...
        optim.coder.qpactiveset.initialize.RemoveDependentIneq_(workingset,qrmanager,memspace,tolfactor);

        [solution.xstar,okWorkingSet,memspace.workspace_double,workingset,qrmanager]=...
        optim.coder.qpactiveset.initialize.feasibleX0ForWorkingSet(memspace.workspace_double,solution.xstar,workingset,qrmanager);
        if(~okWorkingSet)

            tolfactor=10*tolfactor;
            [workingset,qrmanager,memspace]=...
            optim.coder.qpactiveset.initialize.RemoveDependentIneq_(workingset,qrmanager,memspace,tolfactor);

            [solution.xstar,okWorkingSet,memspace.workspace_double,workingset,qrmanager]=...
            optim.coder.qpactiveset.initialize.feasibleX0ForWorkingSet(memspace.workspace_double,solution.xstar,workingset,qrmanager);

            if(~okWorkingSet)
                solution.state=coder.const(optim.coder.SolutionState('DegenerateConstraints'));
                return;
            end
        end
    else
        solution.state=coder.const(optim.coder.SolutionState('InconsistentEq'));
        workingset=optim.coder.qpactiveset.WorkingSet.removeAllIneqConstr(workingset);
        return;
    end




    mFixed=workingset.nWConstr(coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED')));
    mEq=workingset.nWConstr(coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ')));
    nVar=workingset.nVar;

    if(mFixed+mEq==nVar)
        [constrViolation,workingset]=optim.coder.qpactiveset.WorkingSet.maxConstraintViolation(workingset,solution.xstar,INT_ONE);


        if(constrViolation>options.ConstraintTolerance)
            solution.state=coder.const(optim.coder.SolutionState('Infeasible'));
        end

    end

end
