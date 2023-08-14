function obj=setRegularized(obj,quadHasLinear,numQuadVars,beta,rho)














%#codegen

    coder.allowpcode('plain');


    validateattributes(quadHasLinear,{'logical'},{'scalar'});
    validateattributes(numQuadVars,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(beta,{'double'},{'scalar'});
    validateattributes(rho,{'double'},{'scalar'});



    obj.hasLinear=quadHasLinear;
    obj.nvar=numQuadVars;
    obj.objtype=coder.const(optim.coder.qpactiveset.Objective.ID('REGULARIZED'));

    obj.beta=beta;
    obj.rho=rho;

end

