function[WorkingSet,workspace_int]=updateWorkingSet(WorkingSet,TrialState,workspace_int)




























%#codegen

    coder.allowpcode('plain');


    validateattributes(WorkingSet,{'struct'},{'scalar'});
    validateattributes(TrialState,{'struct'},{'scalar'});
    validateattributes(workspace_int,{coder.internal.indexIntClass},{'vector'});




    INT_ONE=coder.internal.indexInt(1);

    AEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AEQ'));
    AINEQ=coder.const(optim.coder.qpactiveset.constants.ConstrNum('AINEQ'));

    mEq=WorkingSet.sizes(AEQ);
    mIneq=WorkingSet.sizes(AINEQ);

    idxIneqOffset=WorkingSet.isActiveIdx(AINEQ);





    if(mEq>0)

        FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));


        for idx=1:mEq
            WorkingSet.beq(idx)=-TrialState.cEq(idx);
        end



        WorkingSet.beq=coder.internal.blas.xgemv('T',WorkingSet.nVar,mEq,...
        1.0,WorkingSet.Aeq,INT_ONE,WorkingSet.ldA,...
        TrialState.searchDir,INT_ONE,INT_ONE,...
        1.0,WorkingSet.beq,INT_ONE,INT_ONE);





        offsetAwEq=WorkingSet.sizes(FIXED);
        WorkingSet.bwset=coder.internal.blas.xcopy(mEq,WorkingSet.beq,INT_ONE,INT_ONE,...
        WorkingSet.bwset,offsetAwEq+1,INT_ONE);
    end

    if(mIneq>0)

        LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));



        for idx=1:mIneq
            WorkingSet.bineq(idx)=-TrialState.cIneq(idx);
        end



        WorkingSet.bineq=coder.internal.blas.xgemv('T',WorkingSet.nVar,mIneq,...
        1.0,WorkingSet.Aineq,INT_ONE,WorkingSet.ldA,...
        TrialState.searchDir,INT_ONE,INT_ONE,...
        1.0,WorkingSet.bineq,INT_ONE,INT_ONE);






        idx_Aineq=coder.internal.indexInt(1);
        idx_lower=WorkingSet.sizes(AINEQ)+1;
        idx_upper=idx_lower+WorkingSet.sizes(LOWER);







        for idx=idxIneqOffset:WorkingSet.nActiveConstr
            TYPE=WorkingSet.Wid(idx);
            idx_IneqLocal=WorkingSet.Wlocalidx(idx);
            switch TYPE
            case AINEQ
                idx_Partition=idx_Aineq;
                idx_Aineq=idx_Aineq+1;
                WorkingSet.bwset(idx)=WorkingSet.bineq(idx_IneqLocal);
            case LOWER
                idx_Partition=idx_lower;
                idx_lower=idx_lower+1;
            otherwise
                idx_Partition=idx_upper;
                idx_upper=idx_upper+1;
            end


            workspace_int(idx_Partition)=idx_IneqLocal;
        end

    end

end


