function obj=removeConstr(obj,idx_global)












%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(idx_global,{coder.internal.indexIntClass},{'scalar'});

    TYPE=obj.Wid(idx_global);
    idx_local=obj.Wlocalidx(idx_global);


    idxConstr=obj.isActiveIdx(TYPE)+idx_local-1;
    obj.isActiveConstr(idxConstr)=false;




    obj=optim.coder.qpactiveset.WorkingSet.moveConstraint_(obj,obj.nActiveConstr,idx_global);


    obj.nActiveConstr(:)=obj.nActiveConstr-1;
    obj.nWConstr(TYPE)=obj.nWConstr(TYPE)-1;

end
