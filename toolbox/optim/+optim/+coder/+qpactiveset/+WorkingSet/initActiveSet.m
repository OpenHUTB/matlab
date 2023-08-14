function obj=initActiveSet(obj,PROBLEM_TYPE)













%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(PROBLEM_TYPE,{coder.internal.indexIntClass},{'scalar'});

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));




    obj=optim.coder.qpactiveset.WorkingSet.setProblemType(obj,PROBLEM_TYPE);


    idxFillStart=obj.isActiveIdx(AINEQ);
    for idx=idxFillStart:obj.mConstrMax
        obj.isActiveConstr(idx)=false;
    end


    obj.nWConstr(FIXED)=obj.sizes(FIXED);
    obj.nWConstr(AEQ)=obj.sizes(AEQ);


    obj.nWConstr(AINEQ)=0;
    obj.nWConstr(LOWER)=0;
    obj.nWConstr(UPPER)=0;

    obj.nActiveConstr(:)=obj.nWConstr(FIXED)+obj.nWConstr(AEQ);


    nWFixed=coder.internal.indexInt(obj.sizes(FIXED));
    for idx_local=1:nWFixed


        idx_global=idx_local;


        obj.Wid(idx_global)=FIXED;
        obj.Wlocalidx(idx_global)=idx_local;


        obj.isActiveConstr(idx_global)=true;


        idx_bound=coder.internal.indexInt(obj.indexFixed(idx_local));
        colOffsetATw=obj.ldA*(idx_global-1);
        for i=1:idx_bound-1
            obj.ATwset(i+colOffsetATw)=0;
        end
        obj.ATwset(idx_bound+colOffsetATw)=1;
        for i=idx_bound+1:obj.nVar
            obj.ATwset(i+colOffsetATw)=0;
        end
        obj.bwset(idx_global)=obj.ub(idx_bound);
    end


    nWeq=coder.internal.indexInt(obj.sizes(AEQ));
    for idx_local=1:nWeq

        idx_global=coder.internal.indexInt(nWFixed+idx_local);



        obj.Wid(idx_global)=AEQ;
        obj.Wlocalidx(idx_global)=idx_local;
        obj.isActiveConstr(idx_global)=true;




        iAeq0=1+obj.ldA*(idx_local-1);
        iATw0=1+obj.ldA*(idx_global-1);






        for i=0:obj.nVar-1
            obj.ATwset(iATw0+i)=obj.Aeq(iAeq0+i);
        end


        obj.bwset(idx_global)=obj.beq(idx_local);
    end

end