function workspace=linearForm_(obj,d,workspace,H,f,x)






















%#codegen

    coder.allowpcode('plain');


    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(d,{'double'},{'scalar'});
    validateattributes(workspace,{'double'},{'2d'});
    validateattributes(H,{'double'},{'2d'});
    validateattributes(f,{'double'},{'2d'});
    validateattributes(x,{'double'},{'vector'});

    coder.internal.prefer_const(d);

    fMultiplier=0.0;
    INT_ONE=coder.internal.indexInt(1);

    if(obj.hasLinear)






        for i=1:obj.nvar
            workspace(i)=f(i);
        end

        fMultiplier=1.0;
    end


    workspace=coder.internal.blas.xgemv('N',obj.nvar,obj.nvar,d,H,INT_ONE,obj.nvar,...
    x,INT_ONE,INT_ONE,fMultiplier,workspace,INT_ONE,INT_ONE);

end

