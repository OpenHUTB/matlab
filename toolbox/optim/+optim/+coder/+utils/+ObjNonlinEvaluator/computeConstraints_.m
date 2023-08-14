function[x,Cineq_workspace,Ceq_workspace,status]=...
    computeConstraints_(obj,x,Cineq_workspace,ineq0,Ceq_workspace,eq0,scales)



















%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(x,{'double'},{'nonempty'});
    validateattributes(Cineq_workspace,{'double'},{'2d'});
    validateattributes(ineq0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(Ceq_workspace,{'double'},{'2d'});
    validateattributes(eq0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(scales,{'struct'},{'scalar'});

    coder.internal.prefer_const(obj,scales,ineq0,eq0);

    SUCCESS=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('Success'));

    if(isempty(obj.nonlcon))



        status=SUCCESS;
        return;
    end




    ineqRange=ineq0+(0:obj.mCineq-1);
    eqRange=eq0+(0:obj.mCeq-1);
    [Cineq_workspace(ineqRange),Ceq_workspace(eqRange)]=obj.nonlcon(x);


    if(obj.ScaleProblem)
        ic0=ineq0-1;
        for idx=1:obj.mCineq
            Cineq_workspace(ic0+idx)=scales.cineq_constraint(idx)*Cineq_workspace(ic0+idx);
        end
        ic0=eq0-1;
        for idx=1:obj.mCeq
            Ceq_workspace(ic0+idx)=scales.ceq_constraint(idx)*Ceq_workspace(ic0+idx);
        end
    end

    status=optim.coder.utils.ObjNonlinEvaluator.internal.checkVectorNonFinite(obj.mCineq,Cineq_workspace,ineq0);

    if(status~=SUCCESS)
        return;
    end

    status=optim.coder.utils.ObjNonlinEvaluator.internal.checkVectorNonFinite(obj.mCeq,Ceq_workspace,eq0);

end