function obj=addUBConstr(obj,idx_local)












%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(idx_local,{coder.internal.indexIntClass},{'scalar'});

    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));
    obj=optim.coder.qpactiveset.WorkingSet.addBoundToActiveSetMatrix_(obj,UPPER,idx_local);
end