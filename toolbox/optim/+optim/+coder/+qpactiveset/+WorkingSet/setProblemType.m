function obj=setProblemType(obj,PROBLEM_TYPE)












%#codegen

    coder.allowpcode('plain');




    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(PROBLEM_TYPE,{coder.internal.indexIntClass},{'scalar'});

    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));

    NORMAL=coder.const(optim.coder.qpactiveset.constants.ConstraintType('NORMAL'));
    PHASEONE=coder.const(optim.coder.qpactiveset.constants.ConstraintType('PHASEONE'));
    REGULARIZED=coder.const(optim.coder.qpactiveset.constants.ConstraintType('REGULARIZED'));
    REG_PHASEONE=coder.const(optim.coder.qpactiveset.constants.ConstraintType('REGULARIZED_PHASEONE'));

    switch PROBLEM_TYPE
    case NORMAL

        obj.nVar=obj.nVarOrig;
        obj.mConstr=obj.mConstrOrig;



        if(obj.nWConstr(UPPER)>0)
            idxUpperNormal=obj.isActiveIdxNormal(UPPER);
            idxUpperExisting=obj.isActiveIdx(UPPER);
            for idx=1:obj.sizesNormal(UPPER)
                obj.isActiveConstr(idxUpperNormal+idx-1)=obj.isActiveConstr(idxUpperExisting+idx-1);
            end
        end

        obj.sizes=obj.sizesNormal;
        obj.isActiveIdx=obj.isActiveIdxNormal;

    case PHASEONE


        obj.nVar=obj.nVarOrig+1;
        obj.mConstr=obj.mConstrOrig+1;
        obj.sizes=obj.sizesPhaseOne;
        obj.isActiveIdx=obj.isActiveIdxPhaseOne;

        obj=optim.coder.qpactiveset.WorkingSet.modifyOverheadPhaseOne_(obj);

    case REGULARIZED

        obj.nVar=obj.nVarMax-1;
        obj.mConstr=obj.mConstrMax-1;
        obj.sizes=obj.sizesRegularized;

        if(obj.probType~=REG_PHASEONE)



            obj=optim.coder.qpactiveset.WorkingSet.modifyOverheadRegularized_(obj);
        end

        obj.isActiveIdx=obj.isActiveIdxRegularized;


    otherwise


        obj.nVar=obj.nVarMax;
        obj.mConstr=obj.mConstrMax;
        obj.sizes=obj.sizesRegPhaseOne;
        obj.isActiveIdx=obj.isActiveIdxRegPhaseOne;

        obj=optim.coder.qpactiveset.WorkingSet.modifyOverheadPhaseOne_(obj);
    end

    obj.probType=PROBLEM_TYPE;

end