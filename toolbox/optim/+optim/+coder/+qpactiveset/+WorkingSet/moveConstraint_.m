function obj=moveConstraint_(obj,idx_global_start,idx_global_dest)













%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(idx_global_start,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(idx_global_dest,{coder.internal.indexIntClass},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);

    obj.Wid(idx_global_dest)=obj.Wid(idx_global_start);
    obj.Wlocalidx(idx_global_dest)=obj.Wlocalidx(idx_global_start);




    for idx=1:obj.nVar
        idxCopyTo=idx+obj.ldA*(idx_global_dest-INT_ONE);
        idxCopyFrom=idx+obj.ldA*(idx_global_start-INT_ONE);
        obj.ATwset(idxCopyTo)=obj.ATwset(idxCopyFrom);
    end
    obj.bwset(idx_global_dest)=obj.bwset(idx_global_start);

end