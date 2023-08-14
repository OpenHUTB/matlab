function tf=isActive(obj,TYPE,idx_local)














%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(TYPE,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(idx_local,{coder.internal.indexIntClass},{'scalar'});

    idxConstr=obj.isActiveIdx(TYPE)+idx_local-1;
    tf=obj.isActiveConstr(idxConstr);
end