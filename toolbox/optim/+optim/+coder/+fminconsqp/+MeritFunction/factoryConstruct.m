function obj=factoryConstruct(fval,Cineq_workspace,ineq0,mNonlinIneq,Ceq_workspace,eq0,mNonlinEq,hasObjective)




















%#codegen

    coder.allowpcode('plain');



    validateattributes(fval,{'double'},{'scalar'});
    validateattributes(Cineq_workspace,{'double'},{'2d'});
    validateattributes(ineq0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mNonlinIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(Ceq_workspace,{'double'},{'2d'});
    validateattributes(eq0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mNonlinEq,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(mNonlinIneq,mNonlinEq);

    INT_ZERO=coder.internal.indexInt(0);

    obj=struct();




    obj.penaltyParam=1.0;
    obj.threshold=1e-4;
    obj.nPenaltyDecreases=INT_ZERO;
    obj.linearizedConstrViol=0.0;

    obj.initFval=fval;

    obj.initConstrViolationEq=optim.coder.fminconsqp.MeritFunction.computeConstrViolationEq_(mNonlinEq,Ceq_workspace,eq0);
    obj.initConstrViolationIneq=optim.coder.fminconsqp.MeritFunction.computeConstrViolationIneq_(mNonlinIneq,Cineq_workspace,ineq0);

    obj.phi=0.0;
    obj.phiPrimePlus=0.0;
    obj.phiFullStep=0.0;


    obj.feasRelativeFactor=0.0;
    obj.nlpPrimalFeasError=0.0;
    obj.nlpDualFeasError=0.0;
    obj.nlpComplError=0.0;
    obj.firstOrderOpt=0.0;

    obj.hasObjective=hasObjective;











end
