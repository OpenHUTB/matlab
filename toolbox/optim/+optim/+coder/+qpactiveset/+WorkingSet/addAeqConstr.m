function obj=addAeqConstr(obj,idx_local)













%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(idx_local,{coder.internal.indexIntClass},{'scalar'});

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));

    totalEq=obj.nWConstr(FIXED)+obj.nWConstr(AEQ);

    if(obj.nActiveConstr==totalEq&&idx_local>obj.nWConstr(AEQ))

        obj=optim.coder.qpactiveset.WorkingSet.addConstrUpdateRecords_(obj,AEQ,idx_local);
        idx_global=obj.nActiveConstr;


        iAeq0=1+obj.ldA*(idx_local-1);
        iAw0=1+obj.ldA*(idx_global-1);





        for idx=1:obj.nVar %#ok<ALIGN>
            obj.ATwset(iAw0+idx-1)=obj.Aeq(iAeq0+idx-1);
        end



        obj.bwset(idx_global)=obj.beq(idx_local);
    else




        idx_newEq=totalEq+1;


        obj.nActiveConstr=obj.nActiveConstr+1;
        obj=optim.coder.qpactiveset.WorkingSet.moveConstraint_(obj,idx_newEq,obj.nActiveConstr);



        obj.nWConstr(AEQ)=obj.nWConstr(AEQ)+1;


        idxConstr=obj.isActiveIdx(AEQ)+idx_local-1;
        obj.isActiveConstr(idxConstr)=true;


        obj.Wid(idx_newEq)=AEQ;
        obj.Wlocalidx(idx_newEq)=idx_local;


        iAeq0=1+obj.ldA*(idx_local-1);
        iAw0=1+obj.ldA*totalEq;





        for idx=1:obj.nVar
            obj.ATwset(iAw0+idx-1)=obj.Aeq(iAeq0+idx-1);
        end


        obj.bwset(idx_newEq)=obj.beq(idx_local);
    end

end