function solution=snap_bounds(solution,workingset)
















%#codegen

    coder.allowpcode('plain');

    validateattributes(solution,{'struct'},{'scalar'});
    validateattributes(workingset,{'struct'},{'scalar'});

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    for idx=1:workingset.sizes(FIXED)
        idxFixed=workingset.indexFixed(idx);
        solution.xstar(idxFixed)=workingset.ub(idxFixed);
    end

    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    for idx=1:workingset.sizes(LOWER)
        idxConstr=workingset.isActiveIdx(LOWER)+idx-1;
        if workingset.isActiveConstr(idxConstr)
            idxLB=workingset.indexLB(idx);
            solution.xstar(idxLB)=-workingset.lb(idxLB);
        end
    end

    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));
    for idx=1:workingset.sizes(UPPER)
        idxConstr=workingset.isActiveIdx(UPPER)+idx-1;
        if workingset.isActiveConstr(idxConstr)
            idxUB=workingset.indexUB(idx);
            solution.xstar(idxUB)=workingset.ub(idxUB);
        end
    end

end

