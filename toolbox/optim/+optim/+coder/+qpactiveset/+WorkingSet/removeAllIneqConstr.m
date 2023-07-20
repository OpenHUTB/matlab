function obj=removeAllIneqConstr(obj)














%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));

    idxStartIneq=obj.nWConstr(FIXED)+obj.nWConstr(AEQ)+1;
    idxEndIneq=coder.internal.indexInt(obj.nActiveConstr);

    for idx_global=idxStartIneq:idxEndIneq
        TYPE=obj.Wid(idx_global);
        idx_local=obj.Wlocalidx(idx_global);


        idxConstr=obj.isActiveIdx(TYPE)+idx_local-1;
        obj.isActiveConstr(idxConstr)=false;
    end


    obj.nWConstr(AINEQ)=0;
    obj.nWConstr(LOWER)=0;
    obj.nWConstr(UPPER)=0;
    obj.nActiveConstr(:)=obj.nWConstr(FIXED)+obj.nWConstr(AEQ);

end