function[rhs,obj]=solve(obj,rhs)













%#codegen

    coder.allowpcode('plain');



    validateattributes(rhs,{'double'},{'2d'});

    INT_ONE=coder.internal.indexInt(1);




    rhs=coder.internal.blas.xtrsv('L','N','U',...
    obj.ndims,obj.FMat,INT_ONE,obj.ldm,rhs,INT_ONE,INT_ONE);


    for idx=INT_ONE:obj.ndims
        idxDiag=idx+obj.ldm*(idx-INT_ONE);
        rhs(idx)=rhs(idx)/obj.FMat(idxDiag);
    end


    rhs=coder.internal.blas.xtrsv('L','T','U',...
    obj.ndims,obj.FMat,INT_ONE,obj.ldm,rhs,INT_ONE,INT_ONE);

end

