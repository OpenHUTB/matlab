function obj=addConstrUpdateRecords_(obj,TYPE,idx_local)












%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(TYPE,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(idx_local,{coder.internal.indexIntClass},{'scalar'});


    obj.nWConstr(TYPE)=obj.nWConstr(TYPE)+1;


    idxConstr=obj.isActiveIdx(TYPE)+idx_local-1;
    obj.isActiveConstr(idxConstr)=true;


    obj.nActiveConstr(:)=obj.nActiveConstr+1;
    idx_global=obj.nActiveConstr;
    obj.Wid(idx_global)=TYPE;
    obj.Wlocalidx(idx_global)=idx_local;

end