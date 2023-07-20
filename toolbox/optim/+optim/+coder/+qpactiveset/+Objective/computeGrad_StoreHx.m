function obj=computeGrad_StoreHx(obj,H,f,x)






















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





        for i=1:obj.nvar-1
            obj.grad(i)=0;
        end

        obj.grad(obj.nvar)=obj.gammaScalar;
    case QUADRATIC


        obj.Hx=coder.internal.blas.xgemv('N',obj.nvar,obj.nvar,1.0,H,INT_ONE,obj.nvar,...
        x,INT_ONE,INT_ONE,0.0,obj.Hx,INT_ONE,INT_ONE);








        for i=1:obj.nvar
            obj.grad(i)=obj.Hx(i);
        end


        if(obj.hasLinear)
            obj.grad=coder.internal.blas.xaxpy(obj.nvar,1.0,f,INT_ONE,INT_ONE,obj.grad,INT_ONE,INT_ONE);
        end

    case REGULARIZED
        maxRegVar=obj.maxVar-1;


        obj.Hx=coder.internal.blas.xgemv('N',obj.nvar,obj.nvar,1.0,H,INT_ONE,obj.nvar,...
        x,INT_ONE,INT_ONE,0.0,obj.Hx,INT_ONE,INT_ONE);


        for idx=obj.nvar+1:maxRegVar
            obj.Hx(idx)=obj.beta*x(idx);
        end







        for i=1:maxRegVar
            obj.grad(i)=obj.Hx(i);
        end


        if(obj.hasLinear)
            obj.grad=coder.internal.blas.xaxpy(obj.nvar,1.0,f,INT_ONE,INT_ONE,obj.grad,INT_ONE,INT_ONE);
        end

        ig0=1+obj.nvar;
        obj.grad=coder.internal.blas.xaxpy(maxRegVar-obj.nvar,1.0,obj.rho,INT_ONE,INT_ZERO,obj.grad,ig0,INT_ONE);
    end

end
