function[x,fval,grad_workspace,Cineq_workspace,Ceq_workspace,JacIneqTrans_workspace,JacEqTrans_workspace,status]=...
    evalObjAndConstrAndDerivatives(obj,x,grad_workspace,iGradStart,...
    Cineq_workspace,ineq0,Ceq_workspace,eq0,...
    JacIneqTrans_workspace,iJI_col,ldJI,...
    JacEqTrans_workspace,iJE_col,ldJE,scales,options)

















































%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(x,{'double'},{'nonempty'});

    validateattributes(grad_workspace,{'double'},{'vector'});
    validateattributes(iGradStart,{coder.internal.indexIntClass},{'scalar'});

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


    coder.internal.prefer_const(obj,scales,options);

    SUCCESS=coder.const(optim.coder.utils.ObjNonlinEvaluator.Constants.FaultToleranceID('Success'));



    if options.SpecifyObjectiveGradient&&~isempty(obj.objfun)
        [x,fval,grad_workspace,status]=...
        optim.coder.utils.ObjNonlinEvaluator.computeObjectiveAndUserGradient_(obj,x,grad_workspace,iGradStart,scales);
    else
        [x,fval,status]=optim.coder.utils.ObjNonlinEvaluator.computeObjective_(obj,x,scales);
    end

    if(status~=SUCCESS)
        return;
    end



    if~isempty(obj.nonlcon)&&options.SpecifyConstraintGradient
        [x,Cineq_workspace,Ceq_workspace,JacIneqTrans_workspace,JacEqTrans_workspace,status]=...
        optim.coder.utils.ObjNonlinEvaluator.computeConstraintsAndUserJacobian_(obj,x,Cineq_workspace,ineq0,Ceq_workspace,eq0,...
        JacIneqTrans_workspace,iJI_col,ldJI,...
        JacEqTrans_workspace,iJE_col,ldJE,scales);
    else
        [x,Cineq_workspace,Ceq_workspace,status]=...
        optim.coder.utils.ObjNonlinEvaluator.computeConstraints_(obj,x,Cineq_workspace,ineq0,Ceq_workspace,eq0,scales);
    end

end

