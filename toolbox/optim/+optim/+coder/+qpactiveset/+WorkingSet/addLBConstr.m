function obj=addLBConstr(obj,idx_local)












%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(idx_local,{coder.internal.indexIntClass},{'scalar'});

    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    obj=optim.coder.qpactiveset.WorkingSet.addBoundToActiveSetMatrix_(obj,LOWER,idx_local);
end