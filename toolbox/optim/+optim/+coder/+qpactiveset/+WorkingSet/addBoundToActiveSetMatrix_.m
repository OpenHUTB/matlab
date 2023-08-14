function obj=addBoundToActiveSetMatrix_(obj,TYPE,idx_local)













%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(TYPE,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(idx_local,{coder.internal.indexIntClass},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));


    obj=optim.coder.qpactiveset.WorkingSet.addConstrUpdateRecords_(obj,TYPE,idx_local);

    idx_global=obj.nActiveConstr;
    colOffset=obj.ldA*(idx_global-INT_ONE);


    switch TYPE
    case UPPER
        idx_bnd_local=obj.indexUB(idx_local);

        obj.bwset(idx_global)=obj.ub(idx_bnd_local);
    otherwise
        idx_bnd_local=obj.indexLB(idx_local);

        obj.bwset(idx_global)=obj.lb(idx_bnd_local);
    end


    for idx=1:idx_bnd_local-1
        obj.ATwset(idx+colOffset)=0;
    end
    obj.ATwset(idx_bnd_local+colOffset)=2*double(TYPE==UPPER)-1;
    for idx=idx_bnd_local+1:obj.nVar
        obj.ATwset(idx+colOffset)=0;
    end


    switch obj.probType
    case coder.const(optim.coder.qpactiveset.constants.ConstraintType('NORMAL'))

    case coder.const(optim.coder.qpactiveset.constants.ConstraintType('REGULARIZED'))

    otherwise

        obj.ATwset(obj.nVar+colOffset)=-1;
    end

end

