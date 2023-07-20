function val=computeMeritFcn(obj,fval,Cineq_workspace,ineq0,mIneq,Ceq_workspace,eq0,mEq,evalWellDefined)













%#codegen

    coder.allowpcode('plain');


    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(fval,{'double'},{'scalar'});
    validateattributes(Cineq_workspace,{'double'},{'2d'});
    validateattributes(ineq0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(Ceq_workspace,{'double'},{'2d'});
    validateattributes(eq0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(evalWellDefined,{'logical'},{'scalar'});

    coder.internal.prefer_const(mIneq,mEq);

    if evalWellDefined
        constrViolationEq=optim.coder.fminconsqp.MeritFunction.computeConstrViolationEq_(mEq,Ceq_workspace,eq0);
        constrViolationIneq=optim.coder.fminconsqp.MeritFunction.computeConstrViolationIneq_(mIneq,Cineq_workspace,ineq0);

        val=fval+obj.penaltyParam*(constrViolationEq+constrViolationIneq);
    else
        val=coder.internal.inf;
    end

end

