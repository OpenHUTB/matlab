function obj=addAineqConstr(obj,idx_local)












%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(idx_local,{coder.internal.indexIntClass},{'scalar'});

    INT_ZERO=coder.internal.indexInt(0);
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));


    obj=optim.coder.qpactiveset.WorkingSet.addConstrUpdateRecords_(obj,AINEQ,idx_local);
    idx_global=obj.nActiveConstr;


    iAineq0=1+obj.ldA*(idx_local-1);
    iAw0=1+obj.ldA*(idx_global-1);
    for idx=INT_ZERO:(obj.nVar-1)
        obj.ATwset(iAw0+idx)=obj.Aineq(iAineq0+idx);
    end


    obj.bwset(idx_global)=obj.bineq(idx_local);
end