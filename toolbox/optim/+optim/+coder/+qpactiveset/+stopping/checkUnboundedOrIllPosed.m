function[solution,objective]=checkUnboundedOrIllPosed(solution,objective)










%#codegen

    coder.allowpcode('plain');

    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(objective,{'struct'},{'scalar'});

    nVar=coder.internal.indexInt(objective.nvar);
    PHASEONE=coder.const(optim.coder.qpactiveset.Objective.ID('PHASEONE'));
    INT_ONE=coder.internal.indexInt(1);

    [TYPE,objective]=optim.coder.qpactiveset.Objective.getObjectiveType(objective);
    if(TYPE==PHASEONE)
        normDelta=coder.internal.blas.xnrm2(nVar,solution.searchDir,INT_ONE,INT_ONE);
        if(normDelta>100*double(nVar)*sqrt(eps('double')))
            solution.state=coder.const(optim.coder.SolutionState('Unbounded'));
        else
            solution.state=coder.const(optim.coder.SolutionState('IllPosed'));
        end
    end

end
