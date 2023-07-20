function[solution,memspace,workingset,qrmanager,cholmanager,objective,options,runTimeOptions]=...
    phaseone(H,f,solution,memspace,workingset,qrmanager,cholmanager,objective,options,runTimeOptions)


























































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

    NORMAL=coder.const(optim.coder.qpactiveset.constants.ConstraintType('NORMAL'));
    PROBTYPE_ORIG=optim.coder.qpactiveset.WorkingSet.getProblemType(workingset);

    nVar=coder.internal.indexInt(workingset.nVar);
    nVarP1=coder.internal.indexInt(workingset.nVar+1);
    solution.xstar(nVarP1)=solution.maxConstr+1;


    if(PROBTYPE_ORIG==NORMAL)
        PHASEONE=coder.const(optim.coder.qpactiveset.constants.ConstraintType('PHASEONE'));
    else
        PHASEONE=coder.const(optim.coder.qpactiveset.constants.ConstraintType('REGULARIZED_PHASEONE'));
    end





    workingset=optim.coder.qpactiveset.WorkingSet.setProblemType(workingset,PHASEONE);

    workingset=optim.coder.qpactiveset.WorkingSet.removeAllIneqConstr(workingset);



    objective=optim.coder.qpactiveset.Objective.setPhaseOne(objective,1.0,nVarP1);


    oldObjLim=options.ObjectiveLimit;
    oldTolX=options.StepTolerance;
    options.ObjectiveLimit=options.ConstraintTolerance*runTimeOptions.ConstrRelTolFactor;
    options.StepTolerance=1e-2*sqrt(eps('double'));


    [solution.fstar,memspace.workspace_double,objective]=...
    optim.coder.qpactiveset.Objective.computeFval(objective,memspace.workspace_double,H,f,solution.xstar);


    solution.state=coder.const(optim.coder.SolutionState('NonOptimal'));


    [solution,memspace,workingset,qrmanager,cholmanager,objective]=...
    optim.coder.qpactiveset.iterate(H,f,solution,memspace,workingset,...
    qrmanager,cholmanager,objective,options,runTimeOptions);

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    startIdx=coder.internal.indexInt(1+workingset.sizes(FIXED)+workingset.sizes(AEQ));



    if(optim.coder.qpactiveset.WorkingSet.isActive(workingset,LOWER,workingset.sizes(LOWER)))
        for idx=startIdx:workingset.nActiveConstr
            if(workingset.Wid(idx)==LOWER)&&(workingset.Wlocalidx(idx)==workingset.sizes(LOWER))
                workingset=optim.coder.qpactiveset.WorkingSet.removeConstr(workingset,idx);
                break;
            end
        end
    end



    mConstr=coder.internal.indexInt(workingset.nActiveConstr);
    mEqFixed=coder.internal.indexInt(workingset.sizes(FIXED)+workingset.sizes(AEQ));
    while(mConstr>mEqFixed&&mConstr>nVar)
        workingset=optim.coder.qpactiveset.WorkingSet.removeConstr(workingset,mConstr);
        mConstr=mConstr-1;
    end


    solution.maxConstr=solution.xstar(nVarP1);


    workingset=optim.coder.qpactiveset.WorkingSet.setProblemType(workingset,PROBTYPE_ORIG);
    objective=optim.coder.qpactiveset.Objective.restoreFromPhaseOne(objective);


    options.ObjectiveLimit=oldObjLim;
    options.StepTolerance=oldTolX;

end
