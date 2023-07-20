function[v,obj]=maxConstraintViolation(obj,x,ix0)















%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});

    validateattributes(ix0,{coder.internal.indexIntClass},{'scalar'});

    FIXED=coder.const(optim.coder.qpactiveset.constants.ConstrNum('FIXED'));
    LOWER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('LOWER'));
    UPPER=coder.const(optim.coder.qpactiveset.constants.ConstrNum('UPPER'));

    mLB=obj.sizes(LOWER);
    mUB=obj.sizes(UPPER);
    mFixed=obj.sizes(FIXED);


    switch obj.probType
    case coder.const(optim.coder.qpactiveset.constants.ConstraintType('REGULARIZED'))
        [v,obj]=optim.coder.qpactiveset.WorkingSet.maxConstraintViolation_AMats_regularized_(obj,x,ix0);
    otherwise
        [v,obj]=optim.coder.qpactiveset.WorkingSet.maxConstraintViolation_AMats_nonregularized_(obj,x,ix0);
    end


    if(mLB>0)
        ix0_start=ix0-1;
        for idx=1:mLB
            idxLB=obj.indexLB(idx);
            v=max(v,-x(ix0_start+idxLB)-obj.lb(idxLB));
        end
    end

    if(mUB>0)
        ix0_start=ix0-1;
        for idx=1:mUB
            idxUB=obj.indexUB(idx);
            v=max(v,x(ix0_start+idxUB)-obj.ub(idxUB));
        end
    end

    if(mFixed>0)
        ix0_start=ix0-1;
        for idx=1:mFixed
            idxFixed=obj.indexFixed(idx);
            v=max(v,abs(x(ix0_start+idxFixed)-obj.ub(idxFixed)));
        end
    end

end