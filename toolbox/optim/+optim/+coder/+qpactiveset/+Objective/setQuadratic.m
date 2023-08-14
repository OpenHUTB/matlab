function obj=setQuadratic(obj,hasLinear,NumVars)












%#codegen

    coder.allowpcode('plain');


    validateattributes(hasLinear,{'logical'},{'scalar'});
    validateattributes(NumVars,{coder.internal.indexIntClass},{'scalar'});

    obj.hasLinear=hasLinear;
    obj.nvar=NumVars;
    obj.objtype=coder.const(optim.coder.qpactiveset.Objective.ID('QUADRATIC'));

end

