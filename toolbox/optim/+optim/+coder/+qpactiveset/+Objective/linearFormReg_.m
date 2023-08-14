function workspace=linearFormReg_(obj,d,workspace,x)






















%#codegen

    coder.allowpcode('plain');


    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(d,{'double'},{'scalar'});
    validateattributes(workspace,{'double'},{'2d'});
    validateattributes(x,{'double'},{'vector'});

    coder.internal.prefer_const(d);






    for idx=obj.nvar+1:obj.maxVar-1
        workspace(idx)=d*obj.beta*x(idx)+obj.rho;
    end

end