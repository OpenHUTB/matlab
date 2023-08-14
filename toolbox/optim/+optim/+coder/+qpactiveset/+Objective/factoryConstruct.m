function obj=factoryConstruct(MaxVars)




























%#codegen

    coder.allowpcode('plain');


    validateattributes(MaxVars,{coder.internal.indexIntClass},{'scalar'});
    coder.internal.prefer_const(MaxVars);

    obj=struct();



    obj.grad=coder.nullcopy(realmax*ones(MaxVars,1,'double'));
    obj.Hx=coder.nullcopy(realmax*ones(MaxVars-1,1,'double'));
    obj.hasLinear=false;
    obj.nvar=coder.internal.indexInt(0);
    obj.maxVar=coder.internal.indexInt(MaxVars);


    obj.beta=0.0;
    obj.rho=0.0;



    obj.objtype=coder.const(optim.coder.qpactiveset.Objective.ID('QUADRATIC'));
    obj.prev_objtype=coder.const(optim.coder.qpactiveset.Objective.ID('QUADRATIC'));
    obj.prev_nvar=coder.internal.indexInt(0);
    obj.prev_hasLinear=false;
    obj.gammaScalar=0.0;








































end

