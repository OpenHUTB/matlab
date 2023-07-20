function obj=modifyOverheadPhaseOne_(obj)












%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));






    for idx=1:obj.sizes(FIXED)
        idxATw=obj.nVar+obj.ldA*(idx-INT_ONE);
        obj.ATwset(idxATw)=0.0;
    end





    eqOffset=obj.isActiveIdx(AEQ)-1;
    for idx=1:obj.sizes(AEQ)
        idxEq=obj.nVar+obj.ldA*(idx-INT_ONE);
        obj.Aeq(idxEq)=0.0;
        obj.ATwset(idxEq+obj.ldA*eqOffset)=0.0;
    end




    for idx=1:obj.sizes(AINEQ)
        idxIneq=obj.nVar+obj.ldA*(idx-INT_ONE);
        obj.Aineq(idxIneq)=-1.0;
    end



    obj.indexLB(obj.sizes(LOWER))=obj.nVar;

    obj.lb(obj.nVar)=obj.SLACK0;



    idxStartIneq=obj.isActiveIdx(AINEQ);
    for idx=idxStartIneq:obj.nActiveConstr
        idxATwIneq=obj.nVar+obj.ldA*(idx-INT_ONE);
        obj.ATwset(idxATwIneq)=-1.0;
    end




    idxUpperExisting=obj.isActiveIdx(UPPER);
    if(obj.nWConstr(UPPER)>0)
        for idx=1:obj.sizesNormal(UPPER)+INT_ONE
            obj.isActiveConstr(idxUpperExisting+idx-INT_ONE)=false;
        end
    end



    obj.isActiveConstr(idxUpperExisting-INT_ONE)=false;

end