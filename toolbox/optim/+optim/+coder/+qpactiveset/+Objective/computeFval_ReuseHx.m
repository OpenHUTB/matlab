function[val,workspace,obj]=computeFval_ReuseHx(obj,workspace,H,f,x)























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
        if(obj.hasLinear)








            for i=1:obj.nvar
                workspace(i)=0.5*obj.Hx(i)+f(i);
            end


            val=coder.internal.blas.xdot(obj.nvar,x,INT_ONE,INT_ONE,workspace,INT_ONE,INT_ONE);
        else

            val=coder.internal.blas.xdot(obj.nvar,x,INT_ONE,INT_ONE,obj.Hx,INT_ONE,INT_ONE);
            val=0.5*val;
        end

    case REGULARIZED
        maxRegVar=obj.maxVar-1;
        if(obj.hasLinear)






            for i=1:obj.nvar
                workspace(i)=f(i);
            end







            for i=1:maxRegVar-obj.nvar
                workspace(obj.nvar+i)=obj.rho;
            end







            for i=1:maxRegVar
                workspace(i)=workspace(i)+0.5*obj.Hx(i);
            end


            val=coder.internal.blas.xdot(maxRegVar,x,INT_ONE,INT_ONE,workspace,INT_ONE,INT_ONE);
        else

            val=coder.internal.blas.xdot(maxRegVar,x,INT_ONE,INT_ONE,obj.Hx,INT_ONE,INT_ONE);
            val=0.5*val;


            for idx=obj.nvar+1:maxRegVar
                val=val+x(idx)*obj.rho;
            end

        end
    end

