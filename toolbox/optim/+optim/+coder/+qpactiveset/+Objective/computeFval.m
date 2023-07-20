function[val,workspace,obj]=computeFval(obj,workspace,H,f,x)

























%#codegen

    coder.allowpcode('plain');

    validateattributes(workspace,{'double'},{'2d'});
    validateattributes(H,{'double'},{'2d'});
    validateattributes(f,{'double'},{'2d'});
    validateattributes(x,{'double'},{'vector'});

    coder.internal.prefer_const(H,f);

    PHASEONE=coder.const(optim.coder.qpactiveset.Objective.ID('PHASEONE'));
    QUADRATIC=coder.const(optim.coder.qpactiveset.Objective.ID('QUADRATIC'));
    REGULARIZED=coder.const(optim.coder.qpactiveset.Objective.ID('REGULARIZED'));

    INT_ONE=coder.internal.indexInt(1);
    val=0.0;




    switch(obj.objtype)
    case PHASEONE
        val=obj.gammaScalar*x(obj.nvar);

    case QUADRATIC

        workspace=optim.coder.qpactiveset.Objective.linearForm_(obj,0.5,workspace,H,f,x);


        val=coder.internal.blas.xdot(obj.nvar,x,INT_ONE,INT_ONE,workspace,INT_ONE,INT_ONE);

    case REGULARIZED

        workspace=optim.coder.qpactiveset.Objective.linearForm_(obj,0.5,workspace,H,f,x);


        workspace=optim.coder.qpactiveset.Objective.linearFormReg_(obj,0.5,workspace,x);




        val=coder.internal.blas.xdot(obj.maxVar-1,x,INT_ONE,INT_ONE,workspace,INT_ONE,INT_ONE);

    end

end


