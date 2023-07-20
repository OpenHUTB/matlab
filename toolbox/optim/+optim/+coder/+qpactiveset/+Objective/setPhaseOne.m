function obj=setPhaseOne(obj,gamma,NumVars)










%#codegen

    coder.allowpcode('plain');


    validateattributes(gamma,{'double'},{'scalar'});
    validateattributes(NumVars,{coder.internal.indexIntClass},{'scalar'});

    obj.prev_objtype=obj.objtype;
    obj.prev_nvar=obj.nvar;
    obj.prev_hasLinear=obj.hasLinear;

    obj.objtype=coder.const(optim.coder.qpactiveset.Objective.ID('PHASEONE'));
    obj.nvar=NumVars;
    obj.gammaScalar=gamma;
    obj.hasLinear=true;

end

