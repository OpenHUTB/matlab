function obj=computeGrad(obj,H,f,x)






















%#codegen

    coder.allowpcode('plain');

    validateattributes(H,{'double'},{'2d'});
    validateattributes(f,{'double'},{'2d'});
    validateattributes(x,{'double'},{'vector'});

    coder.internal.prefer_const(H,f);

    PHASEONE=coder.const(optim.coder.qpactiveset.Objective.ID('PHASEONE'));
    QUADRATIC=coder.const(optim.coder.qpactiveset.Objective.ID('QUADRATIC'));
    REGULARIZED=coder.const(optim.coder.qpactiveset.Objective.ID('REGULARIZED'));

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    switch(obj.objtype)
    case PHASEONE
        obj.grad=coder.internal.blas.xcopy(obj.nvar-1,0.0,INT_ONE,INT_ZERO,obj.grad,INT_ONE,INT_ONE);
        obj.grad(obj.nvar)=obj.gammaScalar;

    case QUADRATIC
        obj.grad=optim.coder.qpactiveset.Objective.linearForm_(obj,1.0,obj.grad,H,f,x);

    case REGULARIZED
        obj.grad=optim.coder.qpactiveset.Objective.linearForm_(obj,1.0,obj.grad,H,f,x);
        obj.grad=optim.coder.qpactiveset.Objective.linearFormReg_(obj,1.0,obj.grad,x);

    end

end

