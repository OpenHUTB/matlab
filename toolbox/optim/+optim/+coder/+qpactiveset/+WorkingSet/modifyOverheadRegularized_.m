function obj=modifyOverheadRegularized_(obj)












%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));

    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));

    mIneq=obj.sizes(AINEQ);
    mEq=obj.sizes(AEQ);

    offsetIneq=obj.nVarOrig;
    offsetEq1=obj.nVarOrig+mIneq;
    offsetEq2=obj.nVarOrig+mIneq+mEq;







    for idx_col=1:obj.sizes(FIXED)
        colOffsetATw=obj.ldA*(idx_col-INT_ONE);
        for idx_row=(obj.nVarOrig+1):obj.nVar
            obj.ATwset(idx_row+colOffsetATw)=0.0;
        end
    end



    for idx_col=1:mIneq
        colOffsetAineq=obj.ldA*(idx_col-INT_ONE);

        for idx_row=(offsetIneq+1):(offsetIneq+idx_col-1)
            obj.Aineq(idx_row+colOffsetAineq)=0.0;
        end
        obj.Aineq(offsetIneq+idx_col+colOffsetAineq)=-1.0;
        for idx_row=(offsetIneq+idx_col+1):obj.nVar
            obj.Aineq(idx_row+colOffsetAineq)=0.0;
        end
    end




    idxGlobalColStart=obj.isActiveIdx(AEQ)-1;
    for idx_col=1:mEq

        colOffsetAeq=obj.ldA*(idx_col-INT_ONE);
        colOffsetATw=colOffsetAeq+obj.ldA*idxGlobalColStart;


        for idx_row=(offsetIneq+1):offsetEq1
            obj.Aeq(idx_row+colOffsetAeq)=0.0;
            obj.ATwset(idx_row+colOffsetATw)=0.0;
        end



        for idx_row=(offsetEq1+1):(offsetEq1+idx_col-1)
            obj.Aeq(idx_row+colOffsetAeq)=0.0;
            obj.ATwset(idx_row+colOffsetATw)=0.0;
        end

        obj.Aeq(offsetEq1+idx_col+colOffsetAeq)=-1.0;
        obj.ATwset(offsetEq1+idx_col+colOffsetATw)=-1.0;

        for idx_row=(offsetEq1+idx_col+1):offsetEq2
            obj.Aeq(idx_row+colOffsetAeq)=0.0;
            obj.ATwset(idx_row+colOffsetATw)=0.0;
        end



        for idx_row=(offsetEq2+1):(offsetEq2+idx_col-1)
            obj.Aeq(idx_row+colOffsetAeq)=0.0;
            obj.ATwset(idx_row+colOffsetATw)=0.0;
        end

        obj.Aeq(offsetEq2+idx_col+colOffsetAeq)=1.0;
        obj.ATwset(offsetEq2+idx_col+colOffsetATw)=1.0;

        for idx_row=(offsetEq2+idx_col+1):obj.nVar
            obj.Aeq(idx_row+colOffsetAeq)=0.0;
            obj.ATwset(idx_row+colOffsetATw)=0.0;
        end
    end


    idx_lb=obj.nVarOrig;
    for idx=obj.sizesNormal(LOWER)+1:obj.sizesRegularized(LOWER)
        idx_lb=idx_lb+1;
        obj.indexLB(idx)=idx_lb;
    end



    if(obj.nWConstr(UPPER)>0)
        idxUpperRegularized=obj.isActiveIdxRegularized(UPPER);
        idxUpperExisting=obj.isActiveIdx(UPPER);
        for idx=1:obj.sizesRegularized(UPPER)
            obj.isActiveConstr(idxUpperRegularized+idx)=obj.isActiveConstr(idxUpperExisting+idx-1);
        end
    end


    for idx=obj.isActiveIdx(UPPER):(obj.isActiveIdxRegularized(UPPER)-INT_ONE)
        obj.isActiveConstr(idx)=false;
    end


    for idx=obj.nVarOrig+1:obj.nVarOrig+mIneq+2*mEq
        obj.lb(idx)=0.0;
    end



    idxStartIneq=obj.isActiveIdx(AINEQ);
    for idx_col=idxStartIneq:obj.nActiveConstr

        colOffsetATw=obj.ldA*(idx_col-INT_ONE);
        switch(obj.Wid(idx_col))
        case AINEQ
            idx_local=obj.Wlocalidx(idx_col);

            for idx_row=(offsetIneq+1):(offsetIneq+idx_local-1)
                obj.ATwset(idx_row+colOffsetATw)=0.0;
            end
            obj.ATwset(offsetIneq+idx_local+colOffsetATw)=-1.0;
            for idx_row=(offsetIneq+idx_local+1):obj.nVar
                obj.ATwset(idx_row+colOffsetATw)=0.0;
            end
        otherwise



            for idx_row=(offsetIneq+1):obj.nVar
                obj.ATwset(idx_row+colOffsetATw)=0.0;
            end
        end
    end

end