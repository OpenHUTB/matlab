function[x,fval,Cineq_workspace,Ceq_workspace,status]=...
    evalObjAndConstr(obj,x,Cineq_workspace,ineq0,Ceq_workspace,eq0,scales)







































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

    [x,fval,status]=optim.coder.utils.ObjNonlinEvaluator.computeObjective_(obj,x,scales);

    if(status~=SUCCESS)
        return;
    end

    [x,Cineq_workspace,Ceq_workspace,status]=...
    optim.coder.utils.ObjNonlinEvaluator.computeConstraints_(obj,x,Cineq_workspace,ineq0,Ceq_workspace,eq0,scales);

end