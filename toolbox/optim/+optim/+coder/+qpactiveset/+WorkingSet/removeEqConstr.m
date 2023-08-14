function obj=removeEqConstr(obj,idx_global)














%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(idx_global,{coder.internal.indexIntClass},{'scalar'});

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));

    totalEq=obj.nWConstr(FIXED)+obj.nWConstr(AEQ);

    if(totalEq==0||idx_global>totalEq)
        return;
    elseif(obj.nActiveConstr==totalEq||idx_global==totalEq)



        obj.mEqRemoved=obj.mEqRemoved+1;
        idx_local=obj.Wlocalidx(idx_global);
        obj.indexEqRemoved(obj.mEqRemoved)=idx_local;

        obj=optim.coder.qpactiveset.WorkingSet.removeConstr(obj,idx_global);
    else







        obj.mEqRemoved=obj.mEqRemoved+1;
        TYPE=obj.Wid(idx_global);
        idx_local=obj.Wlocalidx(idx_global);
        obj.indexEqRemoved(obj.mEqRemoved)=idx_local;


        idxConstr=obj.isActiveIdx(TYPE)+idx_local-1;
        obj.isActiveConstr(idxConstr)=false;


        obj=optim.coder.qpactiveset.WorkingSet.moveConstraint_(obj,totalEq,idx_global);



        obj=optim.coder.qpactiveset.WorkingSet.moveConstraint_(obj,obj.nActiveConstr,totalEq);


        obj.nActiveConstr(:)=obj.nActiveConstr-1;
        obj.nWConstr(TYPE)=obj.nWConstr(TYPE)-1;
    end

end