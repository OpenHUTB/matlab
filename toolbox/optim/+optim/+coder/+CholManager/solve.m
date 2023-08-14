function[rhs,obj]=solve(obj,rhs)













%#codegen

    coder.allowpcode('plain');



    validateattributes(rhs,{'double'},{'2d'});

    INT_ONE=coder.internal.indexInt(1);




    rhs=coder.internal.blas.xtrsv('U','T','N',...
    obj.ndims,obj.FMat,INT_ONE,obj.ldm,rhs,INT_ONE,INT_ONE);


    rhs=coder.internal.blas.xtrsv('U','N','N',...
    obj.ndims,obj.FMat,INT_ONE,obj.ldm,rhs,INT_ONE,INT_ONE);

end

