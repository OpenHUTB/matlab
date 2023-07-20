function[x,Cineq_workspace,Ceq_workspace,...
    JacIneqTrans_workspace,JacEqTrans_workspace,status]=...
    computeConstraintsAndUserJacobian_(obj,...
    x,Cineq_workspace,ineq0,Ceq_workspace,eq0,...
    JacIneqTrans_workspace,iJI_col,ldJI,...
    JacEqTrans_workspace,iJE_col,ldJE,scales)



















%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(x,{'double'},{'nonempty'});
    validateattributes(Cineq_workspace,{'double'},{'2d'});
    validateattributes(ineq0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(Ceq_workspace,{'double'},{'2d'});
    validateattributes(eq0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(JacIneqTrans_workspace,{'double'},{'2d'});
    validateattributes(iJI_col,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldJI,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(JacEqTrans_workspace,{'double'},{'2d'});
    validateattributes(iJE_col,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldJE,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(scales,{'struct'},{'scalar'});

    coder.internal.prefer_const(obj,scales);

    INT_ONE=coder.internal.indexInt(1);

    SUCCESS=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('Success'));

    if(isempty(obj.nonlcon))



        status=SUCCESS;
        return;
    end










    if(obj.mCineq>0&&obj.mCeq>0)
        [Cineq_tmp,Ceq_tmp,JacIneqTrans_tmp,JacEqTrans_tmp]=obj.nonlcon(x);

        Cineq_workspace=coder.internal.blas.xcopy(obj.mCineq,Cineq_tmp,INT_ONE,INT_ONE,Cineq_workspace,ineq0,INT_ONE);
        Ceq_workspace=coder.internal.blas.xcopy(obj.mCeq,Ceq_tmp,INT_ONE,INT_ONE,Ceq_workspace,eq0,INT_ONE);


        for idx_row=INT_ONE:size(JacIneqTrans_tmp,1)
            for idx_col=INT_ONE:size(JacIneqTrans_tmp,2)
                idxJIWkspc=idx_row+ldJI*(iJI_col+idx_col-1-INT_ONE);
                JacIneqTrans_workspace(idxJIWkspc)=JacIneqTrans_tmp(idx_row,idx_col);
            end
        end


        for idx_row=INT_ONE:size(JacEqTrans_tmp,1)
            for idx_col=INT_ONE:size(JacEqTrans_tmp,2)
                idxJEWkspc=idx_row+ldJE*(iJE_col+idx_col-1-INT_ONE);
                JacEqTrans_workspace(idxJEWkspc)=JacEqTrans_tmp(idx_row,idx_col);
            end
        end

    elseif(obj.mCineq>0)
        [Cineq_tmp,~,JacIneqTrans_tmp,~]=obj.nonlcon(x);

        Cineq_workspace=coder.internal.blas.xcopy(obj.mCineq,Cineq_tmp,INT_ONE,INT_ONE,Cineq_workspace,ineq0,INT_ONE);


        for idx_row=INT_ONE:size(JacIneqTrans_tmp,1)
            for idx_col=INT_ONE:size(JacIneqTrans_tmp,2)
                idxJIWkspc=idx_row+ldJI*(iJI_col+idx_col-1-INT_ONE);
                JacIneqTrans_workspace(idxJIWkspc)=JacIneqTrans_tmp(idx_row,idx_col);
            end
        end

    else
        [~,Ceq_tmp,~,JacEqTrans_tmp]=obj.nonlcon(x);

        Ceq_workspace=coder.internal.blas.xcopy(obj.mCeq,Ceq_tmp,INT_ONE,INT_ONE,Ceq_workspace,eq0,INT_ONE);


        for idx_row=INT_ONE:size(JacEqTrans_tmp,1)
            for idx_col=INT_ONE:size(JacEqTrans_tmp,2)
                idxJEWkspc=idx_row+ldJE*(iJE_col+idx_col-1-INT_ONE);
                JacEqTrans_workspace(idxJEWkspc)=JacEqTrans_tmp(idx_row,idx_col);
            end
        end
    end


    if(obj.ScaleProblem)

        ic0=ineq0-1;
        for idx=1:obj.mCineq
            Cineq_workspace(ic0+idx)=scales.cineq_constraint(idx)*Cineq_workspace(ic0+idx);
        end
        ic0=eq0-1;
        for idx=1:obj.mCeq
            Ceq_workspace(ic0+idx)=scales.ceq_constraint(idx)*Ceq_workspace(ic0+idx);
        end




        idx_scales=coder.internal.indexInt(1);
        for idx_col=iJI_col:(iJI_col+obj.mCineq-1)
            for idx_row=1:obj.nVar
                idxJIWkspc=idx_row+ldJI*(idx_col-INT_ONE);
                JacIneqTrans_workspace(idxJIWkspc)=JacIneqTrans_workspace(idxJIWkspc)*scales.cineq_constraint(idx_scales);
            end
            idx_scales=idx_scales+1;
        end


        idx_scales=coder.internal.indexInt(1);
        for idx_col=iJE_col:(iJE_col+obj.mCeq-1)
            for idx_row=1:obj.nVar
                idxJEWkspc=idx_row+ldJE*(idx_col-INT_ONE);
                JacEqTrans_workspace(idxJEWkspc)=JacEqTrans_workspace(idxJEWkspc)*scales.ceq_constraint(idx_scales);
            end
            idx_scales=idx_scales+1;
        end
    end


    status=optim.coder.utils.ObjNonlinEvaluator.internal.checkVectorNonFinite(obj.mCineq,Cineq_workspace,ineq0);

    if(status~=SUCCESS)
        return;
    end

    status=optim.coder.utils.ObjNonlinEvaluator.internal.checkVectorNonFinite(obj.mCeq,Ceq_workspace,eq0);

    if(status~=SUCCESS)
        return;
    end


    status=optim.coder.utils.ObjNonlinEvaluator.internal.checkMatrixNonFinite...
    (obj.nVar,obj.mCineq,JacIneqTrans_workspace,INT_ONE,iJI_col,ldJI);

    if(status~=SUCCESS)
        return;
    end


    status=optim.coder.utils.ObjNonlinEvaluator.internal.checkMatrixNonFinite...
    (obj.nVar,obj.mCeq,JacEqTrans_workspace,INT_ONE,iJE_col,ldJE);

end


